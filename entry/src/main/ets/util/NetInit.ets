/**
 * @author 610965
 * @data 2024/8/2 11:55
 */
import Speedy from '@ohos/Speedy/src/main/ets/Speedy'
import { bundleManager } from '@kit.AbilityKit'
import { TokenIgnore } from './TokenIgnore'

export class NetInit {
  static init() {
    // 根据环境对应不同的url
    Speedy.HOST_URL = (() => {
      switch (NetInit.getEnv()) {
        case Env.PRO:
          return 'https://xxx.xxx.com/router/rest'
        case Env.UAT:
          return 'https://xxx.xxx.com/router/rest'
        case Env.STG:
          return 'https://xxx.xxx.com/router/rest'
        default:
          return 'https://xxx.xxx.com/router/rest'
      }
    })()

    // 自定义请求头
    Speedy.buildHeader = async (url, header, data) => {
      let bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      let requestHeader: Record<string, Object> = {
        'Content-type': 'application/json; charset=UTF-8',
        'format': 'JSON',
        'os': 'harmony',
        "User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:0.9.4)",
        'host': getHost(url),
        'versionCode': bundleInfo.versionCode,
        'versionName': bundleInfo.versionName,
      }
      if (!TokenIgnore.ignoreList.includes(header['method'] + '')) {
        requestHeader['token'] = '' || ""
      }
      return requestHeader
    }

    // 统一处理业务失败:code != 0
    Speedy.trunkFailed = async (header, data, res) => {
      return false
    }
    // 是否提示网络错误
    Speedy.needToastDisConnect = true
    // 网络错误提示内容
    Speedy.disConnectToast = '网络不给力，请稍后重试'
    // 实际网络请求头名字
    Speedy.METHOD_NAME = 'method'
  }

  static getEnv(): Env {
    return Env.UAT
  }
}

export function getHost(url: string): string {
  if (url.indexOf('//') >= 0) {
    let fragment = url.split('//')[1]
    let host = fragment.split('/')[0]
    return host
  }
  return url
}

export enum Env {
  PRO, UAT, STG
}