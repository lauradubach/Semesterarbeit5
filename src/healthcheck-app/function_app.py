import azure.functions as func
import json
import os
import jwt
from jwt import PyJWKClient
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

TENANT_ID = os.environ.get("AAD_TENANT_ID", "f733fdc5-1255-4d8d-b793-2bc7aca0f214")
AUDIENCE = os.environ.get("AAD_AUDIENCE", "api://func-zerotrust-finops-poc")
JWKS_URL = f"https://login.microsoftonline.com/{TENANT_ID}/discovery/v2.0/keys"


def validate_token(auth_header: str):
    if not auth_header or not auth_header.startswith("Bearer "):
        return False, {"error": "missing_or_malformed_bearer_token"}

    token = auth_header.split(" ", 1)[1]
    try:
        jwks_client = PyJWKClient(JWKS_URL)
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=AUDIENCE,
            issuer=f"https://login.microsoftonline.com/{TENANT_ID}/v2.0",
        )
        return True, payload
    except jwt.PyJWTError as e:
        return False, {"error": str(e)}


@app.route(route="HealthCheck")
def HealthCheck(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps({"status": "healthy"}),
        status_code=200,
        mimetype="application/json"
    )


@app.route(route="SecureData")
def SecureData(req: func.HttpRequest) -> func.HttpResponse:
    auth_header = req.headers.get("Authorization")
    valid, info = validate_token(auth_header)

    if not valid:
        return func.HttpResponse(
            json.dumps({"error": "unauthorized", "detail": info.get("error")}),
            status_code=401,
            mimetype="application/json"
        )

    return func.HttpResponse(
        json.dumps({"message": "Zugriff gewährt", "subject": info.get("oid", info.get("sub"))}),
        status_code=200,
        mimetype="application/json"
    )


@app.route(route="ReadSecret")
def ReadSecret(req: func.HttpRequest) -> func.HttpResponse:
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url="https://kv-zerotrust-finops-poc.vault.azure.net/", credential=credential)
    secret = client.get_secret("poc-demo-secret")
    return func.HttpResponse(
        json.dumps({"secret_retrieved": True, "value_length": len(secret.value)}),
        status_code=200,
        mimetype="application/json"
    )