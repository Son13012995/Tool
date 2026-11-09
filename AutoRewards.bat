<# :
@echo off
chcp 65001 >nul
title Auto Microsoft Rewards (PC + Mobile)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ([System.IO.File]::ReadAllText('%~f0', [System.Text.Encoding]::UTF8))"
pause
exit /b
#>

# ==============================================================================
# CẤU HÌNH CHUNG
# ==============================================================================
$TotalSearchesPC = 30
$WaitSecondsPC   = 10
$WorkDir         = "$HOME\BingAuto"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "   BẮT ĐẦU AUTO MICROSOFT REWARDS (PC & MOBILE)       " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# ==============================================================================
# PHẦN 1: CHẠY TÌM KIẾM TRÊN PC (30 LƯỢT)
# ==============================================================================
Write-Host "`n[PHẦN 1] Đang bắt đầu $TotalSearchesPC lượt tìm kiếm trên PC..." -ForegroundColor Yellow

$Prefixes = @("cách", "hướng dẫn", "kinh nghiệm", "tìm hiểu", "mẹo", "tổng hợp")
$Topics   = @("nấu phở bò", "tối ưu mysql", "chạy bộ bền sức", "pha cà phê ngon", "đi phượt vùng cao", "học tiếng nhật it", "code nodejs", "quản lý chi tiêu")
$Suffixes = @("tại nhà", "cho người mới", "nhanh nhất", "hiệu quả", "chi tiết", "năm 2026")

$Questions = New-Object System.Collections.Generic.HashSet[string]
while ($Questions.Count -lt $TotalSearchesPC) {
    $q = "$($Prefixes | Get-Random) $($Topics | Get-Random) $($Suffixes | Get-Random)"
    [void]$Questions.Add($q)
}

$QuestionList = @($Questions)

for ($i = 0; $i -lt $TotalSearchesPC; $i++) {
    $CurrentQuestion = $QuestionList[$i]
    $EncodedQuery = [uri]::EscapeDataString($CurrentQuestion)
    $Url = "https://www.bing.com/search?q=$EncodedQuery&form=QBLH"

    Write-Host "[PC $($i + 1)/$TotalSearchesPC] Đang hỏi: $CurrentQuestion"
    Start-Process "msedge.exe" -ArgumentList $Url

    Write-Host "Chờ $WaitSecondsPC giây..." -ForegroundColor DarkGray
    Start-Sleep -Seconds $WaitSecondsPC
}

Write-Host "-> Hoàn thành phần tìm kiếm PC!`n" -ForegroundColor Green

# ==============================================================================
# PHẦN 2: KIỂM TRA & TỰ ĐỘNG TẢI MÔI TRƯỜNG CHO MÁY MỚI (PORTABLE NODE.JS)
# ==============================================================================
Write-Host "[PHẦN 2] Chuẩn bị môi trường chạy Mobile..." -ForegroundColor Yellow

if (!(Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}
Set-Location $WorkDir

$NodeExe = "node"
$NpmCmd  = "npm"

# Kiểm tra máy đã cài sẵn Node.js chưa
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    $PortableNodeDir = Join-Path $WorkDir "node-portable"
    $PortableNodeExe = Join-Path $PortableNodeDir "node.exe"
    $PortableNpmCmd  = Join-Path $PortableNodeDir "npm.cmd"

    # Nếu chưa có bản Portable trong thư mục thì tự động tải về
    if (!(Test-Path $PortableNodeExe)) {
        Write-Host "Máy chưa có Node.js. Đang tự động tải Node.js Portable (chỉ tải 1 lần đầu)..." -ForegroundColor Cyan
        $NodeZipUrl  = "https://nodejs.org/dist/v20.18.0/node-v20.18.0-win-x64.zip"
        $NodeZipPath = Join-Path $WorkDir "node.zip"

        Invoke-WebRequest -Uri $NodeZipUrl -OutFile $NodeZipPath
        Write-Host "Đang giải nén Node.js Portable..." -ForegroundColor Cyan
        Expand-Archive -Path $NodeZipPath -DestinationPath $WorkDir -Force
        Rename-Item -Path (Join-Path $WorkDir "node-v20.18.0-win-x64") -NewName "node-portable" -Force
        Remove-Item $NodeZipPath -Force
    }

    $env:PATH = "$PortableNodeDir;$env:PATH"
    $NodeExe  = $PortableNodeExe
    $NpmCmd   = $PortableNpmCmd
}

# Kiểm tra và cài đặt playwright-core nếu chưa có
if (!(Test-Path (Join-Path $WorkDir "node_modules\playwright-core"))) {
    Write-Host "Đang cài đặt thư viện playwright-core (chỉ mất ~15s ở lần đầu)..." -ForegroundColor Cyan
    & $NpmCmd init -y | Out-Null
    & $NpmCmd install playwright-core --silent
}

# ==============================================================================
# PHẦN 3: TẠO FILE VÀ CHẠY TÌM KIẾM MOBILE (20 LƯỢT)
# ==============================================================================
Write-Host "`n[PHẦN 3] Bắt đầu 20 lượt tìm kiếm Mobile..." -ForegroundColor Yellow

@'
const { chromium } = require('playwright-core');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const PROFILE_DIR = path.join(__dirname, 'MobileProfile');
const LOGIN_FLAG = path.join(PROFILE_DIR, 'logged_in.txt');

function waitEnter(msg) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => rl.question(msg, () => { rl.close(); resolve(); }));
}

function buildQuestions(total) {
  const p = ["cách làm", "hướng dẫn", "kinh nghiệm", "tổng hợp", "đánh giá", "lịch trình", "mẹo", "tìm hiểu về", "so sánh", "nguyên nhân"];
  const t = ["lập trình nodejs", "tối ưu mysql", "chạy bộ marathon", "du lịch bụi miền bắc", "nấu phở bò", "quản lý tài chính", "học tiếng nhật it", "chăm sóc sức khỏe", "ứng dụng ai mới", "sửa lỗi windows", "chụp ảnh phong cảnh", "quản lý thời gian", "bảo mật mạng", "thiết kế hệ thống", "chọn giày chạy bộ", "pha cà phê phin"];
  const s = ["cho người mới", "hiệu quả nhất", "chi tiết", "năm 2026", "tại nhà", "cơ bản", "nâng cao", "nhanh gọn"];
  const set = new Set();
  while (set.size < total) {
    set.add(`${p[Math.floor(Math.random()*p.length)]} ${t[Math.floor(Math.random()*t.length)]} ${s[Math.floor(Math.random()*s.length)]}`);
  }
  return Array.from(set);
}

(async () => {
  const BING_APP_UA = 'Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/UQ1A.240205.004; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.58 Mobile Safari/537.36 BingSapphire/29.5.211000355';

  const context = await chromium.launchPersistentContext(PROFILE_DIR, {
    channel: 'msedge',
    headless: false,
    userAgent: BING_APP_UA,
    viewport: { width: 412, height: 915 },
    deviceScaleFactor: 2.6,
    isMobile: true,
    hasTouch: true,
    ignoreDefaultArgs: ['--enable-automation'],
    args: [
      '--disable-blink-features=AutomationControlled',
      '--disable-features=UserAgentClientHint',
      '--window-size=430,940'
    ]
  });

  const page = context.pages()[0] || await context.newPage();
  const cdp = await context.newCDPSession(page);

  await cdp.send('Emulation.setUserAgentOverride', {
    userAgent: BING_APP_UA,
    platform: 'Linux armv8l',
    userAgentMetadata: {
      brands: [
        { brand: 'Chromium', version: '130' },
        { brand: 'Android WebView', version: '130' },
        { brand: 'Not?A_Brand', version: '99' }
      ],
      fullVersion: '130.0.6723.58',
      platform: 'Android',
      platformVersion: '14.0.0',
      architecture: 'arm',
      model: 'Pixel 8',
      mobile: true
    }
  });

  await page.goto('https://www.bing.com/?PC=SANSAAND', { waitUntil: 'domcontentloaded' });

  if (!fs.existsSync(LOGIN_FLAG)) {
    console.log('\n======================================================');
    console.log('LẦN ĐẦU CHẠY: Hãy đăng nhập tài khoản Microsoft trên cửa sổ Edge vừa mở.');
    console.log('(Các lần chạy sau tài khoản sẽ tự động được lưu giữ).');
    await waitEnter('Sau khi đăng nhập xong, nhấn phím ENTER tại đây để bắt đầu auto search...');
    fs.writeFileSync(LOGIN_FLAG, 'ok');
    console.log('======================================================\n');
  } else {
    await sleep(2000);
  }

  const questions = buildQuestions(20);

  for (let i = 0; i < questions.length; i++) {
    console.log(`[BING APP ${i + 1}/20] Câu hỏi: "${questions[i]}"`);
    try {
      const box = page.locator('#sb_form_q, textarea[name="q"], input[name="q"]').first();
      await box.waitFor({ state: 'visible', timeout: 8000 });
      await box.click();
      await box.fill('');
      await box.pressSequentially(questions[i], { delay: 65 });
      await Promise.all([
        page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {}),
        box.press('Enter')
      ]);
    } catch {
      await page.goto(`https://www.bing.com/search?q=${encodeURIComponent(questions[i])}&PC=SANSAAND&form=APMCS1`, { waitUntil: 'domcontentloaded' });
    }

    console.log("Đã search xong, chờ 5.5s...");
    await sleep(5500);
  }

  console.log("Hoàn thành 20 lượt tìm kiếm Mobile!");
  await context.close();
  process.exit(0);
})();
'@ | Set-Content -Path "bing-app.js" -Encoding UTF8

& $NodeExe "bing-app.js"

Write-Host "`n======================================================" -ForegroundColor Green
Write-Host "   ĐÃ HOÀN THÀNH TOÀN BỘ NHIỆM VỤ PC & MOBILE!        " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green