/**
 * @author 610965
 * @data 2024/8/1 10:16
 */
import { BaseResponse } from '@ohos/Speedy'

export class RealResponseBean<T> implements BaseResponse<T> {
  success: boolean = false
  code: number = -1 // 错误码
  msg: string = "" // 错误提示
  data: T | null = null
  traceId?: string = ''

  isSuccess(): boolean {
    return this.success
  }

  getData(): T | null {
    return this.data
  }
}