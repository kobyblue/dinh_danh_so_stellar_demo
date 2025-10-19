#![no_std]
use soroban_sdk::{contract, contractimpl, contracttype, symbol_short, Address, BytesN, Env, Symbol, log, IntoVal, TryFromVal};

// --- Định nghĩa các Key để lưu trữ dữ liệu ---
// Sử dụng enum giúp quản lý các key lưu trữ một cách an toàn và rõ ràng.
#[contracttype]
#[derive(Clone)]
enum DataKey {
    Admin,                      // Key cho địa chỉ admin
    Verifier(Address),          // Key để kiểm tra một địa chỉ có phải là verifier không
    Identity(Address),          // Key để lấy thông tin định danh của một user
}

// --- Định nghĩa Trạng thái Định danh ---
// 0: Chưa có, 1: Đang chờ, 2: Đã xác minh, 3: Đã thu hồi
#[contracttype]
#[derive(Clone, Copy, PartialEq, Eq)]
#[repr(u32)]
pub enum IdentityStatus {
    None = 0,
    Pending = 1,
    Verified = 2,
    Revoked = 3,
}

// Chuyển đổi từ u32 sang IdentityStatus để dễ dàng sử dụng trong các hàm
impl TryFrom<u32> for IdentityStatus {
    type Error = ();
    fn try_from(value: u32) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(IdentityStatus::None),
            1 => Ok(IdentityStatus::Pending),
            2 => Ok(IdentityStatus::Verified),
            3 => Ok(IdentityStatus::Revoked),
            _ => Err(()),
        }
    }
}

// --- Định nghĩa Cấu trúc Dữ liệu Định danh ---
#[contracttype]
#[derive(Clone)]
pub struct Identity {
    pub data_hash: BytesN<32>, // Hash của thông tin cá nhân (để đảm bảo quyền riêng tư)
    pub status: IdentityStatus, // Trạng thái hiện tại của định danh
}

#[contract]
pub struct DigitalIdentityContract;

#[contractimpl]
impl DigitalIdentityContract {
    /// === HÀM KHỞI TẠO ===
    /// Khởi tạo contract với địa chỉ của người quản trị (admin).
    /// Hàm này chỉ có thể được gọi một lần duy nhất.
    pub fn initialize(env: Env, admin: Address) {
        // Kiểm tra xem admin đã được thiết lập chưa để đảm bảo hàm chỉ chạy 1 lần
        if env.storage().instance().has(&DataKey::Admin) {
            panic!("Contract đã được khởi tạo");
        }
        // Lưu địa chỉ admin vào storage
        env.storage().instance().set(&DataKey::Admin, &admin);
    }

    /// === HÀM QUẢN TRỊ ===
    /// Thêm một địa chỉ làm người xác minh (verifier).
    /// Chỉ có admin mới có quyền gọi hàm này.
    pub fn add_verifier(env: Env, verifier: Address) {
        // Lấy địa chỉ admin từ storage
        let admin: Address = env.storage().instance().get(&DataKey::Admin).expect("Chưa khởi tạo");
        // Yêu cầu chữ ký từ admin
        admin.require_auth();

        // Lưu verifier vào storage, giá trị `true` chỉ để đánh dấu sự tồn tại
        env.storage().persistent().set(&DataKey::Verifier(verifier.clone()), &true);
        log!(&env, "Them verifier: {}", verifier);
    }

    /// === HÀM CHO NGƯỜI DÙNG ===
    /// Người dùng đăng ký hoặc cập nhật định danh của mình.
    /// `data_hash` là mã SHA256 của thông tin định danh (ví dụ: JSON chứa tên, ngày sinh,...).
    pub fn register(env: Env, user: Address, data_hash: BytesN<32>) {
        // Yêu cầu chữ ký từ chính người dùng để xác thực hành động
        user.require_auth();

        // Tạo một đối tượng Identity mới với trạng thái "Pending"
        let identity = Identity {
            data_hash,
            status: IdentityStatus::Pending,
        };

        // Lưu thông tin định danh vào storage, gắn với địa chỉ của người dùng
        env.storage().persistent().set(&DataKey::Identity(user.clone()), &identity);
        
        // Ghi lại sự kiện (event) đăng ký
        env.events().publish((symbol_short!("register"),), user);
    }

    /// === HÀM CHO NGƯỜI XÁC MINH ===
    /// Verifier cập nhật trạng thái định danh cho một người dùng.
    pub fn verify(env: Env, verifier: Address, user_to_verify: Address, new_status_u32: u32) {
        // Yêu cầu chữ ký từ verifier
        verifier.require_auth();

        // Kiểm tra xem người gọi có phải là một verifier hợp lệ không
        if !env.storage().persistent().has(&DataKey::Verifier(verifier.clone())) {
            panic!("Người gọi không phải là verifier");
        }

        // Lấy thông tin định danh hiện tại của người dùng cần xác minh
        let mut identity: Identity = env
            .storage()
            .persistent()
            .get(&DataKey::Identity(user_to_verify.clone()))
            .expect("Định danh không tồn tại");

        // Cập nhật trạng thái mới
        let new_status = IdentityStatus::try_from(new_status_u32).expect("Trạng thái không hợp lệ");
        identity.status = new_status;

        // Lưu lại thông tin đã cập nhật
        env.storage().persistent().set(&DataKey::Identity(user_to_verify.clone()), &identity);
        
        // Ghi lại sự kiện xác minh
        let topics = (symbol_short!("verify"), verifier);
        env.events().publish(topics, (user_to_verify, new_status_u32));
    }

    /// === HÀM TRUY VẤN ===
    /// Lấy thông tin định danh của một người dùng.
    pub fn get_identity(env: Env, user: Address) -> Option<Identity> {
        env.storage().persistent().get(&DataKey::Identity(user))
    }
}
