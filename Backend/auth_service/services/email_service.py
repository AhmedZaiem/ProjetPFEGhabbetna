from fastapi_mail import MessageSchema
from core.email import fastMail
import os

FRONTEND_URL = os.getenv("FRONTEND_URL")


async def send_activation_email(email: str, token: str):

    activation_link = f"{FRONTEND_URL}/activate?token={token}"

    message = MessageSchema(
        subject="Activate your account",
        recipients=[email],
        body=f"Click the link to activate your account:\n{activation_link}",
        subtype="plain"
    )

    await fastMail.send_message(message)


async def send_password_reset_email(email: str, token: str):

    reset_link = f"{FRONTEND_URL}/reset-password?token={token}"

    message = MessageSchema(
        subject="Reset your password",
        recipients=[email],
        body=f"Click the link to reset your password:\n{reset_link}",
        subtype="plain"
    )

    await fastMail.send_message(message)