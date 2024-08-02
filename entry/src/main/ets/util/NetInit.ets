/**
 * @author 610965
 * @data 2024/8/2 11:55
 */
import Speedy from '@ohos/Speedy/src/main/ets/Speedy'
import { bundleManager } from '@kit.AbilityKit'
import { TokenIgnore } from './TokenIgnore'

export class NetInit {
  static init() {
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

    Speedy.trunkFailed = async (header, res) => {
      return false
    }
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