Speedy鸿蒙版本

语义化回调网络请求

使用示例
Speedy.post("login").onSuccess((res) => { // 接口成功

}).onFail((err) => { // 业务失败
 
}).onError(err => { // 接口失败
 
})
