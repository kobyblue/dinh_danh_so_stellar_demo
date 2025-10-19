# Dự án Smart Contract "Dinh Danh So" (Digital Identity) trên Soroban

Đây là một dự án smart contract được xây dựng trên nền tảng Soroban (Stellar), cung cấp một giải pháp phi tập trung để quản lý và xác minh danh tính kỹ thuật số.

Contract này cho phép một `admin` quản lý danh sách `verifier` (người xác minh), và những `verifier` này có thể cấp, cập nhật, hoặc thu hồi trạng thái định danh của người dùng. Để đảm bảo quyền riêng tư, contract chỉ lưu trữ mã băm (hash) của dữ liệu định danh chứ không lưu thông tin nhạy cảm.

## Cấu trúc Thư mục

Dự án này sử dụng cấu trúc workspace của Rust, với contract chính nằm trong thư mục `contracts`:

```text
.
├── contracts/
│   └── dinh_danh_so/
│       ├── src/
│       │   └── lib.rs      # Mã nguồn smart contract chính
│       └── Cargo.toml      # Phụ thuộc riêng của contract
├── target/                 # Thư mục chứa file .wasm (sau khi build)
├── Cargo.toml              # Cấu hình workspace chung của Rust
├── deploy.sh               # Kịch bản triển khai và tương tác tự động
└── README.md               # Tệp bạn đang đọc

```
## Chạy kịch bản Triển khai:

Đầu tiên, cấp quyền thực thi cho kịch bản:

Bash
chmod +x deploy.sh

Sau đó, chạy kịch bản:

Bash
./deploy.sh