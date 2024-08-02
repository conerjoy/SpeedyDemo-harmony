Speedy鸿蒙版本

利用鸿蒙系统http能力，语义化回调网络请求

使用示例<br>

Speedy.post("login").onSuccess((res) => {
<br>&emsp;// 接口成功<br>
}).onFail((err) => {
<br>&emsp;// 业务失败<br>
}).onError(err => {
<br>&emsp;// 接口失败<br>
})
