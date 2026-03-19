# VPS & Deployment Guide

## Server Details

| Item | Value |
|------|-------|
| Provider | OVH (US) |
| VPS Name | vps-45aafae5.vps.ovh.us |
| OS | Ubuntu 25.04 |
| IP | 40.160.2.223 |
| User | ubuntu |
| SSH Key (local) | `~/.ssh/id_ed25519_vps` |
| OVH Dashboard | https://us.ovh.com/manager |
| Domain | bdfacts.org |

## How to SSH into the VPS

```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223
```

If it says "Permission denied", the SSH key isn't recognized. See "Rescue Mode" below.

## File Locations on the VPS

| What | Path |
|------|------|
| Frontend (what users see) | `/var/www/bdfacts/dist/` |
| Backend (Python API) | `/var/www/bdfacts/backend/` |
| Nginx config | `/etc/nginx/sites-enabled/bdfacts` |
| SSL certs | `/etc/letsencrypt/live/bdfacts.org/` |
| Backend logs | `/tmp/uvicorn.log` |
| Analytics DB | `/var/lib/bdfacts/` |

## Deploying (3 Ways)

### Way 1: Automatic (just push to GitHub)
```bash
git push origin main
```
GitHub Actions will build and deploy automatically. Check status:
```bash
gh run list --limit 3
```

### Way 2: Manual deploy from your Mac
```bash
# Step 1: Build locally
npm run build

# Step 2: Upload to VPS
rsync -avz --delete -e "ssh -i ~/.ssh/id_ed25519_vps" dist/ ubuntu@40.160.2.223:/var/www/bdfacts/dist/

# Step 3: Reload nginx on VPS
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "sudo systemctl reload nginx"
```

### Way 3: Build on VPS (if you have code there)
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223
cd /var/www/bdfacts
git pull
npm run build
sudo systemctl reload nginx
```

## Common Tasks

### Check if the site is running
```bash
curl -o /dev/null -w "%{http_code}" https://bdfacts.org/
# Should print: 200
```

### Restart nginx
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "sudo systemctl reload nginx"
```

### Restart the backend (Python API)
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "sudo pkill -f uvicorn; sleep 2; cd /var/www/bdfacts/backend && sudo nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > /tmp/uvicorn.log 2>&1 &"
```

### Check backend logs
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "tail -50 /tmp/uvicorn.log"
```

### Check disk space
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "df -h"
```

### Check memory usage
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "free -h"
```

### Renew SSL certificate (usually auto-renews)
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223 "sudo certbot renew"
```

## Rescue Mode (When You're Locked Out)

If SSH stops working (key rejected, password doesn't work):

1. Go to https://us.ovh.com/manager
2. Click your VPS → click **"Reboot in rescue mode"**
3. OVH emails you a temporary root password
4. SSH in with that password:
   ```bash
   ssh root@40.160.2.223
   ```
   (If it complains about host key, run `ssh-keygen -R 40.160.2.223` first)
5. Mount the real disk:
   ```bash
   mount /dev/sdb1 /mnt
   ```
6. Fix whatever you need (e.g., add SSH key):
   ```bash
   echo "YOUR_PUBLIC_KEY_HERE" >> /mnt/home/ubuntu/.ssh/authorized_keys
   ```
7. Unmount and reboot to normal:
   ```bash
   umount /mnt
   ```
8. Go back to OVH dashboard → reboot in **normal mode** (LOCAL boot)

## GitHub Actions Secrets

These secrets are configured in GitHub (Settings → Secrets → Actions):

| Secret | What it is |
|--------|-----------|
| `VPS_HOST` | Server hostname |
| `VPS_USER` | SSH username (ubuntu) |
| `VPS_SSH_KEY` | Private SSH key for deployment |
| `VPS_PASSWORD` | Server password (backup) |

To update a secret:
```bash
gh secret set SECRET_NAME --body "new_value"
```

## Nginx Basics

The nginx config is at `/etc/nginx/sites-enabled/bdfacts`. Key parts:
- `root /var/www/bdfacts/dist;` — where it serves files from
- `location /api/` — forwards API calls to the Python backend on port 8000
- `location /` with `try_files $uri /index.html` — makes React Router work (SPA fallback)
- `location /assets/` — caches JS/CSS for 1 year (safe because filenames have hashes)

### Edit nginx config
```bash
ssh -i ~/.ssh/id_ed25519_vps ubuntu@40.160.2.223
sudo nano /etc/nginx/sites-enabled/bdfacts
# After editing:
sudo nginx -t          # Test config (ALWAYS do this first!)
sudo systemctl reload nginx   # Apply changes
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Site shows old version | Clear browser cache, or check if `index.html` is cached: `curl -I https://bdfacts.org/` |
| 404 on all pages | Nginx root is wrong, or `try_files` is missing. Check nginx config |
| 502 Bad Gateway on `/api/` | Backend is down. Restart uvicorn (see above) |
| SSL certificate expired | Run `sudo certbot renew` on the VPS |
| "Permission denied" on deploy | Run `sudo chown -R ubuntu:ubuntu /var/www/bdfacts` on VPS |
| Can't SSH in at all | Use OVH rescue mode (see above) |
| GitHub Actions deploy fails | Check `gh run view <run-id> --log-failed` |
