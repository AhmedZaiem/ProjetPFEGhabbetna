from sqlalchemy.orm import Session
from db.database import SessionLocal
from models.user import User
from models.role import Role
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt_sha256"], deprecated="auto")


def get_password_hash(password: str):
    return pwd_context.hash(password)


def init_admin():
    db: Session = SessionLocal()

    try:
        # Ensure ADMIN role exists
        admin_role = db.query(Role).filter(Role.name == "Admin").first()

        if not admin_role:
            admin_role = Role(name="Admin")
            db.add(admin_role)
            db.commit()
            db.refresh(admin_role)

        # Ensure admin user exists
        admin_user = db.query(User).filter(User.email == "admin@gmail.com").first()

        if not admin_user:
            admin_user = User(
                firstname="Admin",
                lastname="System",
                username="admin",
                email="admin@gmail.com",
                cin="00000000",
                age=30,
                region="system",
                tel="11111111",
                password_hash=get_password_hash("password"),
                role_id=admin_role.id,
                is_verified=True,
                is_blocked=False
            )

            db.add(admin_user)
            db.commit()

        print("✅ Admin initialized successfully")

    except Exception as e:
        print(f"❌ Init admin error: {e}")

    finally:
        db.close()