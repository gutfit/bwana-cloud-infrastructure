# KEYCLOAK SETUP MANUAL - BWANA CLOUD ECOSYSTEM

## Table of Contents
1. [Initial Server Requirements](#server-requirements)
2. [Installation Commands](#installation)
3. [Admin Console Configuration](#admin-console)
4. [Realm Creation - Bwana Cloud](#realm-creation)
5. [Client Configuration](#client-configuration)
6. [User Federation](#user-federation)
7. [Service Integration](#service-integration)
8. [Pre-configured Realm JSON](#pre-configured-realm)

---

## Server Requirements {#server-requirements}

### Minimum Specifications:
```bash
# CPU: 2 cores
# RAM: 4GB
# Storage: 20GB SSD
# Network: 100Mbps
# OS: Ubuntu 20.04+ / CentOS 8+
# Java: OpenJDK 11+
```

### Recommended for Production:
```bash
# CPU: 4 cores
# RAM: 8GB
# Storage: 50GB SSD
# Network: 1Gbps
# Load Balancer: HAProxy/Nginx
# SSL: Wildcard certificate (*.bwana.cloud)
```

---

## Installation {#installation}

### Option 1: Docker (Recommended)
```bash
# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  keycloak:
    image: quay.io/keycloak/keycloak:23.0.0
    container_name: keycloak-bwana
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: EthrAuth$$!!11
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://38.45.71.83:5432/keycloak
      KC_DB_USERNAME: postgres
      KC_DB_PASSWORD: EthrAuth$$!!
      KC_HOSTNAME: sso.bwana.cloud
      KC_HTTP_ENABLED: true
      KC_HTTP_RELATIVE_PATH: /
      KC_PROXY: edge
    ports:
      - "8080:8080"
    volumes:
      - ./keycloak_data:/opt/keycloak/data
    restart: unless-stopped

  postgres-keycloak:
    image: postgres:15
    container_name: postgres-keycloak
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: EthrAuth$$!!
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
EOF

# Start Keycloak
docker-compose up -d
```

### Option 2: Native Installation
```bash
# Download Keycloak
wget https://github.com/keycloak/keycloak/releases/download/23.0.0/keycloak-23.0.0.tar.gz
tar -xzf keycloak-23.0.0.tar.gz
cd keycloak-23.0.0

# Configure database
export KC_DB=postgres
export KC_DB_URL=jdbc:postgresql://38.45.71.83:5432/keycloak
export KC_DB_USERNAME=postgres
export KC_DB_PASSWORD=EthrAuth$$!!

# Start Keycloak
./bin/kc.sh start-dev --http-port=8080 --hostname=sso.bwana.cloud
```

---

## Admin Console Access {#admin-console}

### Initial Login:
```bash
URL: http://localhost:8080/admin
Username: admin
Password: EthrAuth$$!!11
```

### First-Time Setup:
1. Go to **Master Realm** → **Realm Settings**
2. Click **Create Realm**
3. Enter **Realm Name**: `bwana-cloud`
4. Enable **Endpoints**: ON
5. Click **Create**

---

## Realm Creation - Bwana Cloud {#realm-creation}

### Basic Realm Settings:
```bash
Realm Name: bwana-cloud
Display Name: Bwana Cloud
HTML Display Name: Bwana Cloud SSO
Enabled: ON
Registration: ON
Login Theme: keycloak.v2
Account Theme: keycloak.v2
Email Theme: keycloak.v2
```

### Security Settings:
```bash
# Realm Settings → Security Defenses
Brute Force Detection: ON
Permanent Lockout: ON
Max Login Failures: 5
Lockout Duration: 5 minutes
Wait Increment: 1 minute
Max Failure Wait: 15 minutes

# Password Policy
Minimum Length: 12
Digits: 1
Uppercase: 1
Lowercase: 1
Special Characters: 1
Not Username: ON
Not Email: ON
Password History: 5
```

### Email Settings:
```bash
# Realm Settings → Email
Host: smtp.bwana.cloud
Port: 587
From: noreply@bwana.cloud
From Display Name: Bwana Cloud SSO
Reply To: support@bwana.cloud
Enable SSL: ON
Authentication: username/password
Username: noreply@bwana.cloud
Password: [Your SMTP Password]
```

---

## Client Configuration {#client-configuration}

### WordPress Client:
```bash
Client ID: wordpress-bwana
Client Protocol: openid-connect
Access Type: confidential
Standard Flow Enabled: ON
Direct Access Grants: ON
Service Accounts Enabled: ON
Authorization Enabled: OFF

Valid Redirect URIs:
- https://bwana.cloud/*
- https://bwana.cloud/wp-admin/admin-ajax.php
- https://bwana.cloud/wp-login.php

Web Origins:
- https://bwana.cloud

Credentials:
Secret: [Auto-generated - copy this]
```

### Coder Client:
```bash
Client ID: coder-bwana
Client Protocol: openid-connect
Access Type: confidential
Standard Flow Enabled: ON
Service Accounts Enabled: ON

Valid Redirect URIs:
- https://coder.bwana.cloud/*
- https://coder.bwana.cloud/oauth/callback

Web Origins:
- https://coder.bwana.cloud
```

### Plane Client:
```bash
Client ID: plane-bwana
Client Protocol: openid-connect
Access Type: confidential
Standard Flow Enabled: ON
Service Accounts Enabled: ON

Valid Redirect URIs:
- https://plane.bwana.cloud/*
- https://plane.bwana.cloud/auth/callback

Web Origins:
- https://plane.bwana.cloud
```

### AnythingLLM Client:
```bash
Client ID: anythingllm-bwana
Client Protocol: openid-connect
Access Type: confidential
Standard Flow Enabled: ON
Service Accounts Enabled: ON

Valid Redirect URIs:
- https://chat.bwana.cloud/*
- https://chat.bwana.cloud/auth/callback

Web Origins:
- https://chat.bwana.cloud
```

---

## User Federation {#user-federation}

### WordPress User Storage:
```bash
# User Federation → Add Provider → kerberos
Provider ID: wordpress-users
Display Name: WordPress Users
Console Display Name: WordPress Users
Priority: 0
Cache Policy: DEFAULT
Batch Size: 1000
Edit Mode: READ_ONLY
Sync Registrations: ON
```

### LDAP/Active Directory (Optional):
```bash
# User Federation → Add Provider → ldap
Provider ID: ldap-bwana
Display Name: Bwana LDAP
Console Display Name: Bwana LDAP
Priority: 0
Cache Policy: DEFAULT
Batch Size: 1000
Edit Mode: WRITABLE

Connection URL: ldap://ldap.bwana.cloud:389
Bind DN: cn=admin,dc=bwana,dc=cloud
Bind Credential: [LDAP Admin Password]
User DN: ou=users,dc=bwana,dc=cloud
Username LDAP Attribute: uid
RDN LDAP attribute: uid
UUID LDAP attribute: entryUUID
User Object Classes: inetOrgPerson, organizationalPerson
Connection Pooling: ON
Connection Timeout: 5000
Read Timeout: 30000
```

---

## Service Integration {#service-integration}

### WordPress Integration:
```php
// Add to wp-config.php
define('KEYCLOAK_CLIENT_ID', 'wordpress-bwana');
define('KEYCLOAK_CLIENT_SECRET', '[Client Secret]');
define('KEYCLOAK_SERVER_URL', 'https://sso.bwana.cloud');
define('KEYCLOAK_REALM', 'bwana-cloud');

// Install WordPress OAuth plugin
// Plugin: "OpenID Connect Generic Client"
// Configure with above constants
```

### Coder Integration:
```bash
# Environment variables for Coder
KEYCLOAK_CLIENT_ID=coder-bwana
KEYCLOAK_CLIENT_SECRET=[Client Secret]
KEYCLOAK_SERVER_URL=https://sso.bwana.cloud
KEYCLOAK_REALM=bwana-cloud
OAUTH2_CALLBACK_URL=https://coder.bwana.cloud/oauth/callback
```

### Plane Integration:
```bash
# Environment variables for Plane
KEYCLOAK_CLIENT_ID=plane-bwana
KEYCLOAK_CLIENT_SECRET=[Client Secret]
KEYCLOAK_SERVER_URL=https://sso.bwana.cloud
KEYCLOAK_REALM=bwana-cloud
OAUTH2_CALLBACK_URL=https://plane.bwana.cloud/auth/callback
```

---

## Pre-configured Realm JSON {#pre-configured-realm}

### Import Ready Configuration:
```json
{
  "id": "bwana-cloud",
  "realm": "bwana-cloud",
  "displayName": "Bwana Cloud",
  "displayNameHtml": "<div class=\"kc-logo-text\"><span>Bwana</span><span>Cloud</span></div>",
  "enabled": true,
  "registrationAllowed": true,
  "registrationEmailAsUsername": false,
  "rememberMe": true,
  "verifyEmail": true,
  "loginWithEmailAllowed": true,
  "duplicateEmailsAllowed": false,
  "resetPasswordAllowed": true,
  "editUsernameAllowed": true,
  "bruteForceProtected": true,
  "permanentLockout": true,
  "maxFailureWaitSeconds": 900,
  "minimumQuickLoginWaitSeconds": 60,
  "waitIncrementSeconds": 60,
  "quickLoginCheckMilliSeconds": 1000,
  "maxDeltaTimeSeconds": 43200,
  "failureFactor": 30,
  "maxLoginFailures": 5,
  "passwordPolicy": "length(12) and digits(1) and upperCase(1) and lowerCase(1) and specialChars(1) and notUsername(undefined) and notEmail(undefined)",
  "defaultTheme": "keycloak.v2",
  "adminTheme": "keycloak.v2",
  "accountTheme": "keycloak.v2",
  "emailTheme": "keycloak.v2",
  "loginTheme": "keycloak.v2",
  "smtpServer": {
    "host": "smtp.bwana.cloud",
    "port": "587",
    "from": "noreply@bwana.cloud",
    "fromDisplayName": "Bwana Cloud SSO",
    "replyTo": "support@bwana.cloud",
    "ssl": "true",
    "auth": "username-password",
    "user": "noreply@bwana.cloud"
  },
  "browserSecurityHeaders": {
    "contentSecurityPolicyReportOnly": "frame-src 'self'; frame-ancestors 'self'; object-src 'none';",
    "xContentTypeOptions": "nosniff",
    "xRobotsTag": "none",
    "xXSSProtection": "1; mode=block",
    "strictTransportSecurity": "max-age=31536000; includeSubDomains",
    "xFrameOptions": "DENY",
    "contentSecurityPolicy": "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
  },
  "clients": [
    {
      "clientId": "wordpress-bwana",
      "name": "WordPress Bwana Cloud",
      "description": "WordPress integration for Bwana Cloud SSO",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "[GENERATED_SECRET]",
      "redirectUris": [
        "https://bwana.cloud/*",
        "https://bwana.cloud/wp-admin/admin-ajax.php",
        "https://bwana.cloud/wp-login.php"
      ],
      "webOrigins": [
        "https://bwana.cloud"
      ],
      "protocol": "openid-connect",
      "publicClient": false,
      "standardFlowEnabled": true,
      "directAccessGrantsEnabled": true,
      "serviceAccountsEnabled": true,
      "authorizationServicesEnabled": false,
      "fullScopeAllowed": false,
      "attributes": {
        "saml.assertion.signature": "RSA_SHA256",
        "saml.multivalued.roles": "false",
        "saml.force.post.binding": "false",
        "saml.server.signature": "RSA_SHA256",
        "saml.server.signature.keyinfo": "true",
        "exclude.session.state.from.auth.response": "false"
      }
    },
    {
      "clientId": "coder-bwana",
      "name": "Coder Bwana Cloud",
      "description": "Coder development environment SSO",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "[GENERATED_SECRET]",
      "redirectUris": [
        "https://coder.bwana.cloud/*",
        "https://coder.bwana.cloud/oauth/callback"
      ],
      "webOrigins": [
        "https://coder.bwana.cloud"
      ],
      "protocol": "openid-connect",
      "publicClient": false,
      "standardFlowEnabled": true,
      "serviceAccountsEnabled": true,
      "authorizationServicesEnabled": false,
      "fullScopeAllowed": false
    },
    {
      "clientId": "plane-bwana",
      "name": "Plane Bwana Cloud",
      "description": "Plane project management SSO",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "[GENERATED_SECRET]",
      "redirectUris": [
        "https://plane.bwana.cloud/*",
        "https://plane.bwana.cloud/auth/callback"
      ],
      "webOrigins": [
        "https://plane.bwana.cloud"
      ],
      "protocol": "openid-connect",
      "publicClient": false,
      "standardFlowEnabled": true,
      "serviceAccountsEnabled": true,
      "authorizationServicesEnabled": false,
      "fullScopeAllowed": false
    },
    {
      "clientId": "anythingllm-bwana",
      "name": "AnythingLLM Bwana Cloud",
      "description": "AnythingLLM AI assistant SSO",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "[GENERATED_SECRET]",
      "redirectUris": [
        "https://chat.bwana.cloud/*",
        "https://chat.bwana.cloud/auth/callback"
      ],
      "webOrigins": [
        "https://chat.bwana.cloud"
      ],
      "protocol": "openid-connect",
      "publicClient": false,
      "standardFlowEnabled": true,
      "serviceAccountsEnabled": true,
      "authorizationServicesEnabled": false,
      "fullScopeAllowed": false
    }
  ],
  "roles": {
    "realm": [
      {
        "id": "admin",
        "name": "admin",
        "description": "Administrator access to all Bwana Cloud services",
        "composite": false,
        "clientRole": false,
        "containerId": "bwana-cloud",
        "attributes": {}
      },
      {
        "id": "developer",
        "name": "developer",
        "description": "Developer access with coding and deployment permissions",
        "composite": false,
        "clientRole": false,
        "containerId": "bwana-cloud",
        "attributes": {}
      },
      {
        "id": "business-user",
        "name": "business-user",
        "description": "Business user with access to productivity tools",
        "composite": false,
        "clientRole": false,
        "containerId": "bwana-cloud",
        "attributes": {}
      },
      {
        "id": "support",
        "name": "support",
        "description": "Support staff with limited administrative access",
        "composite": false,
        "clientRole": false,
        "containerId": "bwana-cloud",
        "attributes": {}
      }
    ]
  },
  "defaultRoles": [
    "business-user"
  ],
  "requiredActions": [
    {
      "alias": "VERIFY_EMAIL",
      "name": "Verify Email",
      "providerId": "registration",
      "enabled": true,
      "defaultAction": false,
      "priority": 10,
      "config": {}
    },
    {
      "alias": "UPDATE_PASSWORD",
      "name": "Update Password",
      "providerId": "registration",
      "enabled": true,
      "defaultAction": false,
      "priority": 20,
      "config": {}
    },
    {
      "alias": "CONFIGURE_TOTP",
      "name": "Configure TOTP",
      "providerId": "totp",
      "enabled": true,
      "defaultAction": false,
      "priority": 30,
      "config": {}
    }
  ],
  "browserFlow": [
    "identity-provider-redirector",
    "browser",
    "direct-grant-validate-password",
    "auth-cookie",
    "auth-spnego",
    "auth-x509-remote",
    "auth-kerberos"
  ],
  "directGrantFlow": [
    "direct-grant-validate-password",
    "auth-cookie"
  ],
  "attributes": {
    "frontendUrl": "https://sso.bwana.cloud",
    "adminUrl": "https://sso.bwana.cloud/admin",
    "registrationAllowed": "true",
    "registrationEmailAsUsername": "false",
    "rememberMe": "true",
    "verifyEmail": "true",
    "loginWithEmailAllowed": "true",
    "duplicateEmailsAllowed": "false",
    "resetPasswordAllowed": "true",
    "editUsernameAllowed": "true",
    "bruteForceProtected": "true",
    "permanentLockout": "true",
    "maxFailureWaitSeconds": "900",
    "minimumQuickLoginWaitSeconds": "60",
    "waitIncrementSeconds": "60",
    "quickLoginCheckMilliSeconds": "1000",
    "maxDeltaTimeSeconds": "43200",
    "failureFactor": "30",
    "maxLoginFailures": "5",
    "passwordPolicy": "length(12) and digits(1) and upperCase(1) and lowerCase(1) and specialChars(1) and notUsername(undefined) and notEmail(undefined)",
    "defaultTheme": "keycloak.v2",
    "adminTheme": "keycloak.v2",
    "accountTheme": "keycloak.v2",
    "emailTheme": "keycloak.v2",
    "loginTheme": "keycloak.v2"
  }
}
```

---

## Quick Setup Commands {#quick-setup}

### Import Pre-configured Realm:
```bash
# After Keycloak is running, import the realm
curl -X POST \
  http://localhost:8080/admin/realms \
  -H "Authorization: Bearer [ADMIN_TOKEN]" \
  -H "Content-Type: application/json" \
  -d @realm-config.json

# Get admin token
ADMIN_TOKEN=$(curl -X POST \
  http://localhost:8080/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=EthrAuth$$!!11&client_id=admin-cli" | \
  jq -r '.access_token')
```

### SSL Configuration (Production):
```bash
# Generate SSL certificate
certbot certonly --standalone -d sso.bwana.cloud

# Configure Nginx reverse proxy
cat > /etc/nginx/sites-available/keycloak << 'EOF'
server {
    listen 443 ssl http2;
    server_name sso.bwana.cloud;
    
    ssl_certificate /etc/letsencrypt/live/sso.bwana.cloud/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sso.bwana.cloud/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable site
ln -s /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

---

## Testing SSO Integration {#testing}

### Test WordPress Integration:
```bash
# Access WordPress login
https://bwana.cloud/wp-login.php

# Should redirect to Keycloak
https://sso.bwana.cloud/realms/bwana-cloud/protocol/openid-connect/auth?client_id=wordpress-bwana&redirect_uri=https://bwana.cloud/wp-admin/admin-ajax.php&response_type=code&scope=openid+profile+email
```

### Test Service Access:
```bash
# After login, access any service with SSO
https://coder.bwana.cloud
https://plane.bwana.cloud
https://chat.bwana.cloud
```

---

## Troubleshooting {#troubleshooting}

### Common Issues:
1. **Redirect Loop**: Check client redirect URIs
2. **Invalid Client Secret**: Regenerate client secret
3. **CORS Errors**: Add web origins correctly
4. **Database Connection**: Verify PostgreSQL credentials
5. **SSL Issues**: Ensure certificate covers all subdomains

### Debug Commands:
```bash
# Check Keycloak logs
docker logs keycloak-bwana

# Test database connection
psql -h 38.45.71.83 -p 5432 -U postgres -d keycloak

# Check SSL certificate
openssl s_client -connect sso.bwana.cloud:443 -servername sso.bwana.cloud
```

---

## Production Deployment Checklist {#production}

### Security:
- [ ] SSL certificate installed (*.bwana.cloud)
- [ ] Firewall configured (ports 80, 443, 8080)
- [ ] Database backups configured
- [ ] Keycloak backups configured
- [ ] Monitoring and alerting setup
- [ ] Rate limiting configured
- [ ] Security headers verified

### Performance:
- [ ] Load balancer configured
- [ ] Caching enabled
- [ ] Database connection pooling
- [ ] Session clustering
- [ ] CDN for static assets

### High Availability:
- [ ] Multiple Keycloak instances
- [ ] Database clustering
- [ ] Health checks configured
- [ ] Failover testing completed

---

**This manual provides complete setup instructions for Keycloak SSO integration across your entire Bwana Cloud ecosystem.**