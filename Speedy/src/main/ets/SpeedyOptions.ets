/**
 * @author 610965
 * @data 2024/7/18 11:46
 *
 * 网络请求注解
 */
import { http } from '@kit.NetworkKit'
import { BaseResponse } from './BaseResponse'
import Speedy from './Speedy'

export interface SpeedyOptions {
  requestMethod?: http.RequestMethod
  method?: string
  url?: string
  data?: Record<string, Object | Record<string, Object>>
  header?: Record<string, Object>
}


/**
 * 网络请求注解（方法装饰器）
 * 自动发起网络请求，适用于参数固定的接口
 * @param option
 * @returns
 */
export function SpeedyRequest(option: SpeedyOptions) {
  return (target: Object, key: string, descriptor: PropertyDescriptor) => {
    descriptor.value = <T extends BaseResponse<object>>(...args: Object[]) => {
      try {
        let requestMethod = option.requestMethod ?? http.RequestMethod.POST
        if (requestMethod === http.RequestMethod.GET) {
          if (option.url) {
            return Speedy.get<T>(option.url)
          }
        } else if (requestMethod === http.RequestMethod.POST) {
          if (option.method) {
            return Speedy.post<T>(option.method, option.data, option.header)
          }
        }
      } catch (error) {
        console.warn(error)
      }
      return null;
    }
    return descriptor;
  }
}