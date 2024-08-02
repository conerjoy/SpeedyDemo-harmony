/**
 * @author 610965
 * @data 2024/6/4 17:35
 */
import { BaseResponse } from './BaseResponse'

export default class ResponseHandler<T extends BaseResponse<object> = BaseResponse<object>> {
  private status: "pending" | "fulfilled" | "incomplete" | "rejected" | 'finished' = "pending";
  private results: T | null = null;
  private failed: T | null = null
  private failedResponseStr: string = ''
  private error: object | string | number | null = null;
  private resolveCbs: ((results: T | null) => void)[] = [];
  private incompleteCbs: ((results: T, responseStr: string) => void)[] = [];
  private rejectCbs: ((error: object | string | number | null) => void)[] = [];
  private doneCbs: (() => void)[] = [];

  constructor(executor: (onSuccess: (value: T | null) => void, onFail: (value: T, responseStr: string) => void,
    onError: (reason: object | string | number | null) => void, onComplete: () => void) => void) {
    executor((value: T | null): void => {
      this.successFun(value)
    }, (value: T, responseStr: string) => {
      this.failFun(value, responseStr)
    }, (reason: object | string | number | null) => {
      this.errorFun(reason)
    }, () => {
      this.completeFun()
    });
  }

  private successFun(results: T | null): void {
    if (this.status === "pending") {
      this.status = "fulfilled"
      this.results = results
      this.resolveCbs.forEach(cb => cb(results))
    }
  }

  private failFun(failed: T, responseStr: string): void {
    if (this.status === "pending") {
      this.status = "incomplete"
      this.failed = failed
      this.failedResponseStr = responseStr
      console.log(JSON.stringify(failed))
      this.incompleteCbs.forEach(cb => cb(failed, responseStr))
    }
  }

  private errorFun(error: object | string | number | null): void {
    if (this.status === "pending") {
      this.status = "rejected"
      this.error = error
      this.rejectCbs.forEach(cb => cb(error))
    }
  }

  private completeFun() {
    if (this.status === "fulfilled" || this.status === "incomplete" || this.status === "rejected") {
      this.status = "finished"
      this.doneCbs.forEach(cb => cb())
    }
  }

  onSuccess(onSuccessFun: (value: T | null) => void): ResponseHandler<T> {
    // 链式调用 => return Promise
    // 如果 then 方法的回调函数返回一个 Promise 对象，那么 then 方法返回的新 Promise 对象会等待该 Promise 对象的状态变化，然后根据该 Promise 对象的状态再次改变自身状态。
    // 如果 then 方法的回调函数返回一个非 Promise 对象的值，那么 then 方法返回的新 Promise 对象状态为 Resolved，值为该非 Promise 对象的值。
    // 如果 then 方法的回调函数抛出一个异常，那么 then 方法返回的新 Promise 对象状态为 Rejected，值为该异常。
    if (this.status === "pending") {
      this.resolveCbs.push((results) => {
        try {
          onSuccessFun(results)
        } catch (error) {
          this.onError(error)
        }
      })
    } else if (this.status === "fulfilled") {
      // 这里的 try catch 是为了验证.then函数是否能正常执行，以下同
      try {
        onSuccessFun(this.results)
      } catch (error) {
        this.onError(error)
      }
    }
    return this
  }

  onFail(onFailFun: ((value: T | null, responseStr: string) => void)): ResponseHandler<T> {
    if (this.status === "pending") {
      this.incompleteCbs.push((results, str) => {
        try {
          onFailFun(results, str)
        } catch (error) {
          this.onError(error)
        }
      })
    } else if (this.status === "incomplete") {
      // 这里的 try catch 是为了验证.then函数是否能正常执行，以下同
      try {
        onFailFun(this.failed, this.failedResponseStr)
      } catch (error) {
        this.onError(error)
      }
    }
    return this
  }

  onError(onErrorFn: ((reason: object | string | number | null) => void)): ResponseHandler<T> {
    if (this.status === "pending") {
      this.rejectCbs.push((error) => {
        console.log(JSON.stringify(error));
        try {
          onErrorFn(error)
        } catch (error) {
          onErrorFn(error)
        }
      })
    } else if (this.status === "rejected") {
      try {
        onErrorFn(this.error)
      } catch (error) {
        onErrorFn(error)
      }
    }
    return this
  }

  onComplete(onCompleteFn: () => void) {
    if (this.status === "pending") {
      this.doneCbs.push(() => {
        try {
          onCompleteFn()
        } catch (error) {
          this.onError(error)
        }
      })
    } else if (this.status === "finished") {
      try {
        onCompleteFn()
      } catch (error) {
        this.onError(error)
      }
    }
  }

  // 执行catch 回调
  public catch(onErrorFn: (results: object | string | number | null) => void) {
    return this.onError(onErrorFn)
  }
}