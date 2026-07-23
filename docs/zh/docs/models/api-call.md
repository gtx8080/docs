# 模型调用

思明智算中心平台 提供了两种大模型的托管方式，您可以根据自己的需求任选其一：

- MaaS by Token：使用 Token 计费，共享资源，用户无需部署模型实例即可调用模型
- 模型服务：用户独享实例，按实例计费，API 调用次数不受限制

## 目前支持的模型与托管方式

| 模型名称                      | MaaS by Token | 模型服务 |
| ----------------------------- | ------------- | -------- |
| 🔥 DeepSeek-R1                | ✅            |          |
| 🔥 DeepSeek-V3                | ✅            |          |
| Phi-4                         |               | ✅       |
| Phi-3.5-mini-instruct         |               | ✅       |
| Qwen2-0.5B-Instruct           |               | ✅       |
| Qwen2.5-7B-Instruct           | ✅            | ✅       |
| Qwen2.5-14B-Instruct          |               | ✅       |
| Qwen2.5-Coder-32B-Instruct    |               | ✅       |
| Qwen2.5-72B-Instruct-AWQ      | ✅            | ✅       |
| baichuan2-13b-Chat            |               | ✅       |
| Llama-3.2-11B-Vision-Instruct | ✅            | ✅       |
| glm-4-9b-chat                 | ✅            | ✅       |

## 模型 Endpoint

模型 Endpoint 是一个可供用户访问的 URL 或 API 地址，用于发送请求以调用模型进行推理。

| 调用方式      | Endpoint            |
| ------------- | ------------------- |
| MaaS by Token | `https://chat.d.run`        |
| 模型服务      | `<region>.d.run` |

## API 调用示例

### 使用 MaaS by Token 调用

要使用 MaaS by Token 调用模型，请按照以下步骤操作：

1. **获取 API Key**：登录用户控制台，[创建一个新的 API Key](./apikey.md)
2. **设置 Endpoint**：将 SDK 的 endpoint 替换为 `https://chat.d.run`
3. **调用模型**：使用官方的模型名称和新的 API Key 进行调用

**示例代码 (Python)**：

```python
import openai

openai.api_key = "your-api-key" # 替换为您的 API Key
openai.api_base = "https://chat.d.run/v1"

response = openai.ChatCompletion.create(
    model="public/deepseek-v3",
    messages=[{"role": "user", "content": "What is your name?"}],
)

print(response.choices[0].message["content"])
```

### 使用独立模型服务调用

要使用自己部署的模型实例进行调用，请按照以下步骤操作：

1. **部署模型实例**：在指定的区域部署模型实例，例如 `sh-02`
2. **获取 API Key**：登录用户控制台，创建一个新的 API Key
3. **设置 Endpoint**：将 SDK 的 endpoint 替换为 `<region>.d.run`，例如 `sh-02.d.run`
4. **调用模型**：使用官方的模型名称和新的 API Key 进行调用

**示例代码 (Python)**：

```python
import openai

openai.api_key = "your-api-key" # 替换为您的 API Key
openai.api_base = "https://sh-02.d.run" # 替换为您的模型服务所在的区域

response = openai.Completion.create(
  model="u-1100a15812cc/qwen2", # 替换为您的模型服务访问名称
  prompt="What is your name?"
)

print(response.choices[0].text)
```

## 常见问题

### Q1 如何选择调用方式？

- **MaaS by Token**：适用于轻量级、不频繁的调用场景
- **Instance**：适用于需要高性能、频繁调用的场景

### Q2 如何查看我的 API Key？

登录用户控制台，进入 API Key 管理页面即可查看和管理您的 API Key，参考 [API Key 管理](apikey.md)。

### Q3 如何获取模型名称？

- MaaS by Token 的模型名称由 `public/` 和模型名称组成，例如 `public/deepseek-r1`，可在模型详情页查看。
- 模型服务部署的模型名称由用户名和模型名称组成，例如 `u-1100a15812cc/qwen2`，可在模型列表一键复制。

### Q4 部署模型实例的费用如何计算？

费用根据部署的区域、实例规格和使用时长计算。具体费用请参考用户控制台的实例定价页面。

## 支持与反馈

如有任何问题或反馈，请联系我们的[技术支持团队](../contact/index.md)。
