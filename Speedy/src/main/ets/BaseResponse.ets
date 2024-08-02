/**
 * @author 610965
 * @data 2024/8/2 10:21
 */
export interface BaseResponse<T> {
  code: number // 错误码
  data: T | null
}