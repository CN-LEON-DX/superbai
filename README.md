-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "citext";

-- Xóa các bảng cũ nếu tồn tại
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS chat_message;
DROP TABLE IF EXISTS chat_session;
DROP TABLE IF EXISTS workspace;
DROP TABLE IF EXISTS workflow_access;
DROP TABLE IF EXISTS userprofile;
DROP TABLE IF EXISTS workflow;
DROP TABLE IF EXISTS account;

-- 1. Bảng account (quản lý tài khoản)
CREATE TABLE account (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gmail CITEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, 
    salt TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Bảng userprofile (thông tin người dùng)
CREATE TABLE userprofile (
    user_id UUID PRIMARY KEY REFERENCES account(user_id) ON DELETE CASCADE,
    name VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    name_company VARCHAR(100),
    role VARCHAR(50), -- chức danh trong công ty
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Bảng workflow
CREATE TABLE workflow (
    id_workflow UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    webhook_url TEXT,
    header_auth_value TEXT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Bảng workflow_access
CREATE TABLE workflow_access (
    id SERIAL PRIMARY KEY,
    id_workflow UUID REFERENCES workflow(id_workflow) ON DELETE CASCADE,
    user_id UUID REFERENCES account(user_id) ON DELETE CASCADE,
    can_view BOOLEAN NOT NULL DEFAULT TRUE,
    can_edit BOOLEAN NOT NULL DEFAULT FALSE,
    can_share BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_workflow, user_id)
);

-- 5. Bảng workspace
CREATE TABLE workspace (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES account(user_id) ON DELETE CASCADE,
    id_workflow UUID REFERENCES workflow(id_workflow) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, id_workflow)
);

-- 6. Bảng chat_session
CREATE TABLE chat_session (
    chat_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workspace_id INTEGER REFERENCES workspace(id) ON DELETE CASCADE,
    title VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Bảng chat_message
CREATE TABLE chat_message (
    id BIGSERIAL PRIMARY KEY,
    chat_id UUID REFERENCES chat_session(chat_id) ON DELETE CASCADE,
    sender_id UUID REFERENCES account(user_id),
    message TEXT,
    audio_url TEXT,
    file_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Function đăng ký (đơn giản)
CREATE OR REPLACE FUNCTION fn_register(
    p_gmail CITEXT,
    p_password_hash TEXT, -- Đã được hash từ backend
    p_name VARCHAR(100),
    p_phone VARCHAR(20),
    p_company VARCHAR(100),
    p_role VARCHAR(50)
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Tạo tài khoản với password đã hash
    INSERT INTO account (gmail, password_hash)
    VALUES (p_gmail, p_password_hash)
    RETURNING user_id INTO v_user_id;

    -- Tạo profile
    INSERT INTO userprofile (
        user_id,
        name,
        phone,
        name_company,
        role
    )
    VALUES (
        v_user_id,
        p_name,
        p_phone,
        p_company,
        p_role
    );

    RETURN json_build_object(
        'status', 'success',
        'user_id', v_user_id,
        'gmail', p_gmail,
        'name', p_name
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'status', 'error',
        'message', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- Function đăng nhập (đơn giản)
CREATE OR REPLACE FUNCTION fn_login(
    p_gmail CITEXT,
    p_password_hash TEXT  -- Đã được hash từ backend
)
RETURNS JSON AS $$
DECLARE
    v_user_record RECORD;
BEGIN
    -- Kiểm tra tài khoản với password đã hash
    SELECT 
        a.user_id,
        a.gmail,
        up.name,
        up.phone,
        up.name_company,
        up.role
    INTO v_user_record
    FROM account a
    LEFT JOIN userprofile up ON up.user_id = a.user_id
    WHERE a.gmail = p_gmail 
    AND a.password_hash = p_password_hash;

    IF v_user_record.user_id IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Email hoặc mật khẩu không đúng'
        );
    END IF;

    RETURN json_build_object(
        'status', 'success',
        'user_id', v_user_record.user_id,
        'gmail', v_user_record.gmail,
        'name', v_user_record.name,
        'company', v_user_record.name_company,
        'role', v_user_record.role
    );
END;
$$ LANGUAGE plpgsql;

-- Tạo một số index cơ bản
CREATE INDEX idx_account_gmail ON account(gmail);
CREATE INDEX idx_workspace_user ON workspace(user_id);
CREATE INDEX idx_chat_message_chat ON chat_message(chat_id);