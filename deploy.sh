#!/bin/bash

# Dừng lại ngay lập tức nếu có lỗi
set -e

# --- Bước 1: Thiết lập danh tính và mạng ---
# Sử dụng mạng Testnet của Stellar
NETWORK="--network testnet"

# Hàm để tạo danh tính nếu nó chưa tồn tại
create_identity_if_not_exists() {
    local name=$1
    echo "🔑 Kiểm tra danh tính '$name'..."
    # Lệnh `stellar keys address` sẽ thất bại nếu key không tồn tại.
    # Toán tử `||` sẽ chỉ chạy lệnh `stellar keys generate` KHI lệnh trước đó thất bại.
    if ! stellar keys address "$name" > /dev/null 2>&1; then
        echo "   -> Tạo danh tính mới cho '$name'..."
        stellar keys generate "$name"
    else
        echo "   -> Danh tính '$name' đã tồn tại."
    fi
}

# Tạo các danh tính (tài khoản) cần thiết
create_identity_if_not_exists deployer
create_identity_if_not_exists admin
create_identity_if_not_exists verifier
create_identity_if_not_exists user_1

# Lấy địa chỉ public key của từng tài khoản
DEPLOYER_PK=$(stellar keys address deployer)
ADMIN_PK=$(stellar keys address admin)
VERIFIER_PK=$(stellar keys address verifier)
USER_PK=$(stellar keys address user_1)

# Nạp tiền cho các tài khoản vừa tạo bằng Friendbot trên Testnet
# Lưu ý: Friendbot có thể giới hạn số lần gọi, nếu bạn chạy script quá nhiều lần có thể sẽ gặp lỗi.
echo "💰 Nạp tiền cho các tài khoản (nếu cần)..."
# Chúng ta sẽ kiểm tra số dư trước khi gọi friendbot để tránh gọi quá nhiều lần
# (Phần này là nâng cao, hiện tại chúng ta tạm bỏ qua để đơn giản hóa)
echo "   - Gọi Friendbot cho Deployer..."
curl -s "https://friendbot.stellar.org/?addr=$DEPLOYER_PK" > /dev/null
echo "   - Gọi Friendbot cho Admin..."
curl -s "https://friendbot.stellar.org/?addr=$ADMIN_PK" > /dev/null
echo "   - Gọi Friendbot cho Verifier..."
curl -s "https://friendbot.stellar.org/?addr=$VERIFIER_PK" > /dev/null
echo "   - Gọi Friendbot cho User..."
curl -s "https://friendbot.stellar.org/?addr=$USER_PK" > /dev/null

echo "✅ Đã sẵn sàng các tài khoản."
echo "   - Deployer: $DEPLOYER_PK"
echo "   - Admin: $ADMIN_PK"
echo "   - Verifier: $VERIFIER_PK"
echo "   - User: $USER_PK"

# --- Bước 2: Biên dịch Smart Contract ---
echo "🛠️ Đang biên dịch smart contract..."
stellar contract build

# Sửa đường dẫn đến file WASM cho đúng với kết quả build của bạn
# Hãy chắc chắn rằng bạn đang sử dụng đúng target wasm.
# Nếu bạn build ra `wasm32-unknown-unknown` thì dùng dòng dưới:
WASM_PATH="./target/wasm32v1-none/release/dinh_danh_so.wasm"
# Nếu bạn build ra `wasm32v1-none` và tên project là `hello-world`:
# WASM_PATH="./target/wasm32v1-none/release/hello_world.wasm"


# --- Bước 3: Triển khai Smart Contract ---
echo "🚀 Đang triển khai smart contract lên Testnet..."
# Người triển khai (deployer) sẽ trả phí cho giao dịch này
CONTRACT_ID=$(stellar contract deploy --wasm $WASM_PATH --source deployer $NETWORK)
echo "✅ Đã triển khai! Contract ID: $CONTRACT_ID"

# --- Bước 4: Tương tác với Smart Contract (CÚ PHÁP ĐÃ SỬA) ---
echo "▶️ Gọi hàm 'initialize' với vai trò Admin..."
stellar contract invoke \
    --id $CONTRACT_ID \
    --source deployer \
    $NETWORK \
    -- \
    initialize \
    --admin "$ADMIN_PK"

echo "▶️ Gọi hàm 'add_verifier' để thêm Verifier..."
stellar contract invoke \
    --id $CONTRACT_ID \
    --source admin \
    $NETWORK \
    -- \
    add_verifier \
    --verifier "$VERIFIER_PK"

echo "▶️ Người dùng 'user_1' đăng ký định danh..."
USER_DATA_HASH=$(openssl rand -hex 32)
echo "   - Data Hash: $USER_DATA_HASH"
stellar contract invoke \
    --id $CONTRACT_ID \
    --source user_1 \
    $NETWORK \
    -- \
    register \
    --user "$USER_PK" \
    --data_hash "$USER_DATA_HASH"

echo "🔍 Kiểm tra trạng thái định danh của 'user_1' (sau khi đăng ký)..."
stellar contract invoke \
    --id $CONTRACT_ID \
    --source deployer \
    $NETWORK \
    -- \
    get_identity \
    --user "$USER_PK"

echo "▶️ 'Verifier' xác minh định danh cho 'user_1'..."
stellar contract invoke \
    --id $CONTRACT_ID \
    --source verifier \
    $NETWORK \
    -- \
    verify \
    --verifier "$VERIFIER_PK" \
    --user_to_verify "$USER_PK" \
    --new_status_u32 2

echo "🔍 Kiểm tra lại trạng thái định danh của 'user_1' (sau khi xác minh)..."
stellar contract invoke \
    --id $CONTRACT_ID \
    --source deployer \
    $NETWORK \
    -- \
    get_identity \
    --user "$USER_PK"

echo "🎉 Quy trình hoàn tất!"
