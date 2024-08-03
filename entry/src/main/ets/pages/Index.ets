import Speedy from '@ohos/Speedy/src/main/ets/Speedy';
import { RealResponseBean } from '../util/RealResponseBean';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    // Speedy.post<RealResponseBean<UserInfo>>('user/login', {
    //   'phone': '19912345678',
    //   'password': 'xxxxxx'
    // }).onSuccess((res) => {
    //   const userinfo = res?.data
    // }).onFail((res) => {
    //   if (res?.code == 111) {
    //     // 尝试次数过多，请稍后重试
    //   }
    // }).onError((err) => {
    //   console.warn(err?.toString())
    // }).onComplete(() => {
    //   // 接口完成
    // })
    //
    // Speedy.postUrl<RealResponseBean<UserInfo>>('user/login', {
    //   'phone': '19912345678',
    //   'password': 'xxxxxx'
    // }).onSuccess((res) => {
    //   const userinfo = res?.data
    // }).onFail((res) => {
    //   if (res?.code == 111) {
    //     // 尝试次数过多，请稍后重试
    //   }
    // }).onError((err) => {
    //   console.warn(err?.toString())
    // }).onComplete(() => {
    //   // 接口完成
    // })
    //
    // Speedy.get<RealResponseBean<UserInfo>>('https://xxx.xxx.com/user/login', {
    //   'phone': '19912345678',
    //   'password': 'xxxxxx'
    // }).onSuccess((res) => {
    //   const userinfo = res?.data
    // }).onFail((res) => {
    //   if (res?.code == 111) {
    //     // 尝试次数过多，请稍后重试
    //   }
    // }).onError((err) => {
    //   console.warn(err?.toString())
    // }).onComplete(() => {
    //   // 接口完成
    // })
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}