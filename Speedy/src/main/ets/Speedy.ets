/**
 * @author 610965
 * @data 2024/6/4 10:49
 */
import http from '@ohos.net.http'
import { BaseResponse } from './BaseResponse'
import ResponseHandler from './ResponseHandler'
import hilog from '@ohos.hilog'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'

/*
 * 使用示例
 * Speedy.post("login").onSuccess((res) => { // 接口成功
 *
 *   }).onFail((err) => { // 业务失败
 *
 *   }).onError(err => { // 接口失败
 *
 *   })
 */
export default class Speedy {
  static buildHeader: ((url: string, header: object, data: object) => Promise<Record<string, Object>>) | null = null
  // 是否提示网络错误
  static needToastDisConnect = true
  // 网络错误提示内容
  static disConnectToast = '网络不给力，请稍后重试'
  // 网络请求url
  static HOST_URL: string
  // 实际网络请求头名字
  static METHOD_NAME = 'method'
  /**
   * 请求失败的总处理方法
   * @returns 是否消费此次事件
   */
  static trunkFailed: <T>(header: object, data: object, res: BaseResponse<T>) => Promise<boolean>

  /**
   * get方式发起网络请求
   *
   * @param url
   * @returns
   */
  static get<T extends BaseResponse<object> = BaseResponse<object>>(url: string): ResponseHandler<T> {
    return requestCore(url, http.RequestMethod.GET, new Object())
  }

  /**
   * post方式发起网络请求
   *
   * 适合统一网关平台，实际请求放置在header中
   *
   * @param method
   * @param data
   * @param header
   * @returns
   */
  static post<T extends BaseResponse<object> = BaseResponse<object>>(method: string, data: Record<string, Object | Record<string, Object>> = {},
    header: Record<string, Object> = {}): ResponseHandler<T> {
    header[Speedy.METHOD_NAME] = method
    return requestCore(Speedy.HOST_URL, http.RequestMethod.POST, data, header)
  }

  /**
   * post方式发起网络请求
   *
   * 适合 https://xxx.xxx.com/xxx 拼接 user/login
   *
   * @param url
   * @param data
   * @param header
   * @returns
   */
  static postUrl<T extends BaseResponse<object> = BaseResponse<object>>(url: string, data: Record<string, Object | Record<string, Object>> = {},
    header: Record<string, Object> = {}): ResponseHandler<T> {
    return requestCore(Speedy.HOST_URL + url, http.RequestMethod.POST, data, header)
  }
}

/**
 * 超时时间
 */
export const TIME_OUT_DURATION: number = 20000

export function request<T extends BaseResponse<object> = BaseResponse<object>>(requestMethod: http.RequestMethod, data: object,
  header: object = new Object()): ResponseHandler<T> {
  return requestCore<T>(Speedy.HOST_URL, requestMethod, data, header)
}

export function requestCore<T extends BaseResponse<object> = BaseResponse<object>>(url: string, requestMethod: http.RequestMethod,
  data: object, header: object = new Object()): ResponseHandler<T> {
  return new ResponseHandler<T>(async (onSuccess, onFail, onError, onComplete) => {
    try {
      let requestHeader: Record<string, Object> = await Speedy.buildHeader?.(url, header, data) ?? {}
      let allHeader = assign(requestHeader, header)
      http.createHttp().request(url, {
        method: requestMethod,
        header: allHeader,
        extraData: data,
        readTimeout: TIME_OUT_DURATION,
        connectTimeout: TIME_OUT_DURATION
      }).then(async (response) => {
        if (response.responseCode == http.ResponseCode.OK) {
          let res: T = JSON.parse(response.result.toString())
          if (res.code == 0) {
            onSuccess(res)
            onComplete()
          } else {
            if (!await Speedy.trunkFailed(allHeader, data, res)) {
              onFail(res, response.result.toString())
            }
            onComplete()
          }
        } else {
          if (Speedy.needToastDisConnect) {
            promptAction.showToast({ message: Speedy.disConnectToast })
          }
          onError(response.result)
          onComplete()
        }
        hilog.info(0, "Net", warpLog(url, allHeader, data, response))
      }).catch((err: BusinessError) => {
        onError(err)
        onComplete()
        hilog.info(0, "Net", warpLog(url, allHeader, data, null, err))
      })
    } catch (err) {
      hilog.info(0, "Net", "网络请求异常:执行出错\n" + JSON.stringify(err))
      onError(err)
      onComplete()
    }
  })
}

/**
 * 包装网络请求log
 * @param url
 * @param header
 * @param data
 * @param response
 * @param err
 * @returns
 */
function warpLog(url: string, header: object, data: object, response: http.HttpResponse | null = null, err: BusinessError | null = null): string {
  let startLog = ''
  const headerLog = JSON.stringify(header).replace(/,/g, ',\n').replace('{', '').replace('}', '') + '\n'
  const bodyLog = JSON.stringify(data) + '\n'
  let dataLog = ''
  const endLog = `<-- END HTTP\n`
  if (response) {
    startLog = `<-- ${response.responseCode} ${url} ${response.performanceTiming.totalTiming}ms\n`
    dataLog = response.result.toString() + '\n'
  } else {
    startLog = `\n<-- ${-1} ${url}\n`
    dataLog = (err?.message ?? '') + '\n'
  }
  return startLog + headerLog + bodyLog + dataLog + endLog
}

export function assign(target: Record<string, Object>, ...source: Object[]): Record<string, Object> {
  for (const items of source) {
    for (const key of Object.keys(items)) {
      target[key] = Reflect.get(items, key)
    }
  }
  return target;
}