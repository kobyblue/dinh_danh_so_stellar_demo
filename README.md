# 🌐 Digital Identities – Smart Contract on Stellar

### 👥 Thành viên nhóm
- **Bùi Lê Minh**  
- **Đặng Tuấn Cảnh**  
- **Nguyễn Nam Khánh**

---

## 📖 Giới thiệu dự án

**Digital Identities** là một **smart contract** được phát triển trên **Stellar Soroban** nhằm quản lý danh tính số (Digital Identity) theo hướng **phi tập trung và an toàn**.

Hợp đồng này cho phép người dùng tự quản lý thông tin của mình, đăng ký, xác minh và thu hồi các thuộc tính danh tính (như email, chứng chỉ, số CCCD...) thông qua blockchain mà không cần bên thứ ba kiểm soát.

---

## 🧩 Mục tiêu

- Tạo môi trường **xác minh danh tính** minh bạch và bảo mật.  
- Trao **quyền kiểm soát dữ liệu cá nhân** cho chính người dùng.  
- Giảm thiểu rủi ro rò rỉ thông tin thông qua cơ chế **hash và selective disclosure**.  
- Hỗ trợ khả năng **tự động hoá (automation)** và **liên thông (interoperability)** giữa các nền tảng.

---

## ⚙️ Các chức năng chính

| Chức năng | Mô tả |
|------------|--------|
| `init(admin)` | Thiết lập địa chỉ quản trị (chạy 1 lần khi khởi tạo) |
| `register(subject)` | Đăng ký danh tính cho người dùng |
| `set_attr(subject, key, value_hash, expires_at)` | Gán thuộc tính danh tính dạng hash |
| `request_verification(subject, key, verifier)` | Đề xuất một verifier xác nhận thuộc tính |
| `verify_attr(verifier, subject, key)` | Verifier xác thực thuộc tính |
| `revoke_attr(subject, key)` | Thu hồi thuộc tính |
| `get_attr(subject, key)` | Truy xuất thông tin thuộc tính hiện tại |

---

## 🧱 Công nghệ sử dụng

- **Rust** + `soroban-sdk`  
- **Stellar CLI** (để build, deploy, invoke hợp đồng)  
- **WASM target**: `wasm32v1-none`  
- **Testnet** của Stellar

---

## 🗂 Cấu trúc thư mục

```
digital-identity/
├─ Cargo.toml
├─ rust-toolchain.toml
├─ README.md
├─ scripts/
│  ├─ build.sh / build.ps1
│  ├─ deploy.sh / deploy.ps1
│  └─ invoke.sh / invoke.ps1
└─ contracts/
   └─ digital_id/
      ├─ Cargo.toml
      └─ src/
         ├─ lib.rs
         └─ test.rs
```

---

## 🚀 Hướng dẫn chạy

### 1️⃣ Cài đặt môi trường
- Cài **Rust** và **Stellar CLI** theo hướng dẫn tại [developers.stellar.org](https://developers.stellar.org/docs/build/smart-contracts)
- Thêm target build:
  ```bash
  rustup target add wasm32v1-none
  ```

### 2️⃣ Build hợp đồng
```bash
./scripts/build.sh
```
(Windowns PowerShell: `.\scriptsuild.ps1`)

### 3️⃣ Deploy lên testnet
```bash
./scripts/deploy.sh
```

### 4️⃣ Chạy demo flow
```bash
./scripts/invoke.sh
```

---

## 🔐 Bảo mật & Quyền riêng tư
- Dữ liệu người dùng không lưu trực tiếp mà dưới dạng **băm (hash)**.  
- Người dùng chỉ chia sẻ dữ liệu khi cần, qua cơ chế **selective disclosure**.  
- Có thể mở rộng để tích hợp với **DID (Decentralized Identifiers)** hoặc **Verifiable Credentials**.

---

## 📅 Phiên bản hiện tại

**Version:** `0.1.0`  
**Ngày cập nhật:** 2025-10-19

---

## 🧠 Định hướng phát triển tương lai

- Tích hợp DID off-chain registry  
- Giao diện Web UI (React + Stellar SDK)  
- Module xác thực KYC tự động  
- Hỗ trợ lưu trữ phân tán (IPFS/Arweave)

---

## 📝 Giấy phép sử dụng

MIT License © 2025 – Nhóm Digital Identities
