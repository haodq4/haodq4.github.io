---
title: "Tăng Tốc Delivery: Chuyển Từ 'Vibe Code' Sang 'Spec-First' với AI Assistant"
date: 2025-09-14
draft: false
tags: ["dev", "ai", "spec-kit", "workflow", "delivery"]
description: "Làm sao để một dự án hoàn thành thật nhanh mà chất lượng vẫn ngon? Bài viết này chia sẻ một quy trình làm việc đột phá với Spec-Kit và AI để tăng tốc độ delivery đáng kể."
---

<p align="center">
  <img src="/images/post4/cover.jpg" alt="cover" width="800" />
</p>

Thời gian gần đây tôi làm việc rất nhiều với AI. Lúc đầu thì dùng nó như một trợ lý code — hỏi, trả lời, sinh code mẫu. Nhưng càng về sau tôi nhận ra: nếu không có một “khung” rõ ràng thì AI dễ bịa code hoặc làm mọi thứ lộn xộn.

Tôi bắt đầu quan tâm đến hướng spec-first: viết đặc tả (spec) thật rõ, rồi để AI code theo spec đó. Đúng lúc này GitHub tung ra Spec Kit — một bộ công cụ giúp chúng ta áp dụng Spec-Driven Development một cách gọn gàng.

Và khi kết hợp với AI (ở đây tôi chọn Gemini CLI), mọi thứ thực sự trở nên nhanh hơn rất nhiều.

### Chuẩn bị

Yêu cầu môi trường:
- Linux / macOS (hoặc Windows + WSL2)
- Python 3.11+
- Git
- `uv` hoặc `uvx`
- Gemini CLI (cài bằng `npm install -g @google/gemini-cli`)

---

### Khởi tạo Project với Spec Kit

Theo tài liệu chính thức, bạn chỉ cần một lệnh duy nhất để vừa cài đặt Spec Kit, vừa khởi tạo project mới. Lệnh này sử dụng `uvx` để chạy tool trực tiếp từ repository trên GitHub.

Để tạo một project mới tên là `my-todo-app` và cấu hình sẵn cho Gemini, bạn chạy lệnh sau:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init my-todo-app --ai gemini
```

Kết quả là Spec Kit sinh ra một scaffold project với 4 thư mục chính: `memory/`, `scripts/`, `specs/`, `templates/`.

<p align="center">
  <img src="/images/post4/image1.png" alt="Single Server Diagram" width="1000" />
</p>

<p align="center">
  <img src="/images/post4/image2.png" alt="Single Server Diagram" width="1000" />
</p>

---

### Làm việc với Gemini

Sau khi khởi tạo project, bạn di chuyển vào thư mục `my-todo-app` và bắt đầu làm việc với Gemini CLI:

```bash
cd my-todo-app
gemini
```

Bắt đầu bằng việc viết spec:
```
/specify A simple todo app: create, update, delete, mark tasks as done. Each task has title, description, and deadline.
```

<p align="center">
  <img src="/images/post4/image3.png" alt="Single Server Diagram" width="1000" />
</p>

Tiếp đó, tôi để Gemini giúp tôi lập plan:
```
/plan Frontend: React + Vite. Backend: Java + Spring Boot. Database: PostgreSQL. Auth: JWT.
```

<p align="center">
  <img src="/images/post4/image4.png" alt="Single Server Diagram" width="1000" />
</p>

Từ plan, tôi generate tasks:
```
/tasks
```

<p align="center">
  <img src="/images/post4/image5.png" alt="Single Server Diagram" width="1000" />
</p>


Và cuối cùng, tôi yêu cầu Gemini code theo danh sách task vừa được tạo ra:

<p align="center">
  <img src="/images/post4/image6.png" alt="Single Server Diagram" width="1000" />
</p>

Tôi bắt đầu implement task đầu tiên `T001`

```
Based on specs/001-a-simplem-todo/spec.md and plan.md, task.md please implememt task `T001`
```

Và 2 project `backend` và `frontend` nhanh chóng được tạo ta.

<p align="center">
  <img src="/images/post4/image7.png" alt="Single Server Diagram" width="1000" />
</p>

---

### Giải thích cấu trúc project

Scaffold của Spec Kit trông như sau:
```
├── memory
│    ├── constitution.md
│    └── constitution_update_checklist.md
├── scripts
│    ├── check-task-prerequisites.sh
│    ├── common.sh
│    ├── create-new-feature.sh
│    ├── get-feature-paths.sh
│    ├── setup-plan.sh
│    └── update-claude-md.sh
├── specs
│    └── 001-todo-app
│         └── spec.md
└── templates
     ├── plan-template.md
     ├── spec-template.md
     └── tasks-template.md
```

- `memory/`: lưu các rule, assumption, constitution của project.
- `scripts/`: shell script tiện ích (tạo feature, check prerequisite…).
- `specs/`: nơi tôi đặt đặc tả từng feature.
- `templates/`: các file mẫu để team giữ format đồng nhất.

<p align="center">
  <img src="/images/post4/image8.png" alt="Single Server Diagram" width="500" />
</p>

---

### Bài học rút ra

Khi làm việc theo hướng spec-first:
- AI bám sát đặc tả, code ít sai hơn.
- Team có chung ngôn ngữ: spec chính là hợp đồng.
- Refactor hay scale dự án dễ kiểm soát.

Spec Kit chính là cầu nối giúp tôi biến ý tưởng thành code nhanh hơn, gọn hơn, mà vẫn giữ được sự kiểm soát.

---

### Kết

Sau vài ngày thử nghiệm, tôi thấy workflow `specify` → `/specify` → `/plan` → `/tasks` → code thực sự hiệu quả. Nếu bạn cũng đang dùng AI để code, hãy thử một lần spec-first với Spec Kit.

Có thể bạn sẽ ngạc nhiên giống tôi: code chạy nhanh hơn, ít bug hơn, và cảm giác kiểm soát cũng tốt hơn hẳn!
