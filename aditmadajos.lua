--VERSION:1.0
--CHANGELOG_START
- Versi awal lokal sebelum diperbarui otomatis
--CHANGELOG_END

require "import"
import "android.content.Intent"
import "android.net.Uri"
import "android.os.Handler"
import "android.os.Looper"
import "android.widget.LinearLayout"
import "android.widget.TextView"
import "android.widget.Button"
import "android.view.Gravity"
import "java.lang.Runnable"

-- ================= KONFIGURASI UPDATE =================
local currentVersion = "1.0"
local repoUrl = "https://raw.githubusercontent.com/aditmada89-spec/SamAditMada/main/aditmadajos.lua"
local scriptPath = package.searchpath("main", package.path) or (os.getenv("EXTERNAL_STORAGE") .. "/main.lua")
local baseDir = scriptPath:match("(.*/)") or (os.getenv("EXTERNAL_STORAGE") .. "/")
local timeCacheFile = baseDir .. "gh_last_check.txt"

-- ================= FUNGSI AUTO CHECK =================
local function checkUpdate()
  local currentTime = os.time()
  
  -- Mode pengujian: langsung cek ke GitHub tanpa batasan jeda 24 jam
  pcall(function()
    Http.get(repoUrl, function(code, content)
      if code == 200 and content then
        -- Simpan waktu pengecekan terakhir
        local tw = io.open(timeCacheFile, "w")
        if tw then 
          tw:write(tostring(currentTime)) 
          tw:close() 
        end
        
        local onlineVersion = content:match("%-%-VERSION:([^\n\r]+)")
        if onlineVersion and onlineVersion ~= currentVersion then
          local changelog = content:match("%-%-CHANGELOG_START(.-)%-%-CHANGELOG_END") or "\n- Tidak ada catatan spesifik."
          
          -- Tulis SELURUH content agar header versi tidak hilang untuk update berikutnya
          local file = io.open(scriptPath, "w")
          if file then
            file:write(content)
            file:close()
            
            Handler(Looper.getMainLooper()).post(Runnable{run = function()
              local dUpdate = LuaDialog(service)
              dUpdate.setTitle("Pembaruan Otomatis Selesai")
              
              local lUp = LinearLayout(service)
              lUp.setOrientation(1)
              lUp.setPadding(30, 30, 30, 30)
              
              local tUp = TextView(service)
              tUp.setText("Versi Baru: " .. onlineVersion .. "\nCatatan Pembaruan:" .. changelog .. "\n\nSistem telah menimpa file ini dengan versi terbaru. Silakan jalankan ulang eksekusi.")
              lUp.addView(tUp)
              
              local bUp = Button(service)
              bUp.setText("Tutup")
              bUp.setOnClickListener(function() dUpdate.dismiss() end)
              lUp.addView(bUp)
              
              dUpdate.setView(lUp)
              dUpdate.show()
              service.speak("Skrip berhasil diperbarui secara otomatis.")
            end})
          end
        end
      end
    end)
  end)
end

-- Jalankan pengecekan otomatis saat skrip mulai
checkUpdate()

-- ================= LOGIKA AUTO CLICK & UI =================
local E_KEY = "\xF0\x9F\x94\x91"
local E_INFO = "\xE2\x84\xB9\xEF\xB8\x8F"
local E_STAR = "\xE2\x9C\xA8"
local E_ROCKET = "\xF0\x9F\x9A\x80"
local E_BOOK = "\xF0\x9F\x93\x96"
local E_COFFEE = "\xE2\x98\x95"
local E_PHONE = "\xF0\x9F\x93\xB1"
local E_LAUGH = "\xF0\x9F\xA4\xA3"
local E_LOCK = "\xF0\x9F\x94\x90"
local E_ROBOT = "\xF0\x9F\xA4\x96"

local handler = Handler(Looper.getMainLooper())
local menuDlg
local hasClickedNav = false

local function tryClickNode(node)
  if not node then return false end
  if node.isClickable() then
    return node.performAction(16)
  end
  local parent = node.getParent()
  if parent and parent.isClickable() then
    return parent.performAction(16)
  end
  return false
end

local function scanAndClick(node)
  if not node then return 0 end
  local text = node.getText() and tostring(node.getText()):lower() or ""
  local desc = node.getContentDescription() and tostring(node.getContentDescription()):lower() or ""
  
  if text:find("coba lagi") or desc:find("coba lagi") or text:find("try again") or desc:find("try again") then
    if tryClickNode(node) then return 1 end
  end
  
  if text:find("create api key") or text:find("buat kunci api") or text:find("create key")
    or desc:find("create api key") or desc:find("buat kunci api") or desc:find("create key") then
    if tryClickNode(node) then return 2 end
  end
  
  if not hasClickedNav then
    if (text == "kunci api" or text == "api keys" or desc == "kunci api" or desc == "api keys") then
      if tryClickNode(node) then
        hasClickedNav = true
        return 3
      end
    end
  end
  
  local count = node.getChildCount()
  for i = 0, count - 1 do
    local child = node.getChild(i)
    if child then
      local res = scanAndClick(child)
      if res > 0 then return res end
    end
  end
  return 0
end

local function startAutoClick(attempt)
  attempt = attempt or 1
  if attempt > 35 then return end
  
  handler.postDelayed(Runnable{
    run = function()
      local root = service.getRootInActiveWindow()
      if root then
        local actionCode = scanAndClick(root)
        if actionCode == 2 then
          return
        elseif actionCode == 3 then
          service.postSpeak(999, "Membuka menu kunci API, bersiap klik buat kunci")
        end
      end
      startAutoClick(attempt + 1)
    end
  }, 1000)
end

local function showAboutDialog()
  local aboutDlg = LuaDialog(service)
  aboutDlg.setTitle(E_BOOK .. " Tentang Plugin & Kitab Sakti Kaum Mager " .. E_LAUGH)
  
  local rootLayout = LinearLayout(service)
  rootLayout.setOrientation(LinearLayout.VERTICAL)
  rootLayout.setPadding(40, 25, 40, 20)
  
  local tvMessage = TextView(service)
  tvMessage.setText(E_STAR .. " Panduan Resmi Anti Pusing Kepala:\n\n"
    .. E_KEY .. " Menu Login & Buat Kunci API: Ini adalah jalur ekspres kelas eksekutif tanpa calo! Kamu tinggal klik, lalu pilih mau ke Gemini (Google AI Studio) atau ke Groq (yang banter kayak jet tempur itu " .. E_ROCKET .. "). Kalau browser kamu belum login, sistem pinter mereka bakal nyuruh login dulu. Kalau udah login, Jieshuo bakal auto-gerilya nyari tombol 'Create API key' sampai kepencet sendiri tanpa kamu harus cape-cape ngusap layar sampai lecet! Tugas kamu cuma santai sambil ngopi " .. E_COFFEE .. ".\n\n"
    .. E_PHONE .. " Catatan Penting & Sakral: Tolong dipastikan paket data internet masih bernyawa dan kuota bukan sisa 0 KB. Jangan sampai kamu ngamuk-ngamuk ke layar HP gegara tombolnya nggak kepencet, padahal HP kamu lagi mode offline kayak di goa purba!\n\n"
    .. E_LOCK .. " Kalau kuncinya udah nongol: Tinggal kamu salin (copy) baik-baik, jangan disebarin ke grup arisan keluarga atau status WA, nanti kuota gratisan AI-mu ludes dipakai keponakan bikin PR sekolah!\n\n"
    .. E_ROBOT .. " Alat ini dibuat oleh SamAditMada.")
  tvMessage.setTextSize(16)
  rootLayout.addView(tvMessage)
  
  local rowLayout = LinearLayout(service)
  rowLayout.setOrientation(LinearLayout.HORIZONTAL)
  rowLayout.setGravity(Gravity.CENTER)
  rowLayout.setPadding(0, 30, 0, 10)
  
  local btnParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0)
  btnParams.setMargins(10, 0, 10, 0)
  
  local btnWa = Button(service)
  btnWa.setText("WhatsApp")
  btnWa.setLayoutParams(btnParams)
  btnWa.setOnClickListener(function(v)
    aboutDlg.dismiss()
    local waIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/6282228197405"))
    waIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    service.startActivity(waIntent)
  end)
  
  local btnTg = Button(service)
  btnTg.setText("Telegram")
  btnTg.setLayoutParams(btnParams)
  btnTg.setOnClickListener(function(v)
    aboutDlg.dismiss()
    local tgIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://t.me/ekstensi_indonesia"))
    tgIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    service.startActivity(tgIntent)
  end)
  
  rowLayout.addView(btnWa)
  rowLayout.addView(btnTg)
  rootLayout.addView(rowLayout)
  
  local btnCloseParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
  btnCloseParams.setMargins(10, 10, 10, 0)
  
  local btnClose = Button(service)
  btnClose.setText("Tutup")
  btnClose.setLayoutParams(btnCloseParams)
  btnClose.setOnClickListener(function(v)
    aboutDlg.dismiss()
    if menuDlg then
      menuDlg.show()
      local listView = menuDlg.getListView()
      if listView then
        listView.setSelection(1)
        handler.postDelayed(Runnable{
          run = function()
            local root = service.getRootInActiveWindow()
            if root then
              local nodes = root.findAccessibilityNodeInfosByText("Tentang Plugin")
              if nodes and nodes.size() > 0 then
                nodes.get(0).performAction(64)
              end
            end
          end
        }, 150)
      end
    end
  end)
  rootLayout.addView(btnClose)
  
  aboutDlg.setView(rootLayout)
  aboutDlg.show()
end

local function showProviderDialog()
  local provDlg = LuaDialog(service)
  provDlg.setTitle(E_KEY .. " Pilih Layanan AI")
  local items = String{
    E_STAR .. " Google AI Studio (Gemini)",
    E_ROCKET .. " Groq Console"
  }
  local urls = {
    "https://aistudio.google.com/app/apikey",
    "https://console.groq.com/keys"
  }
  provDlg.setItems(items)
  provDlg.setOnItemClickListener(function(parent, v, position, id)
    hasClickedNav = false
    local intent = Intent(Intent.ACTION_VIEW, Uri.parse(urls[position + 1]))
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    service.startActivity(intent)
    service.speak("Membuka halaman dan bersiap klik otomatis")
    startAutoClick(1)
    provDlg.dismiss()
  end)
  
  provDlg.setNegativeButton("Batal", function(d)
    d.dismiss()
    if menuDlg then
      menuDlg.show()
      local listView = menuDlg.getListView()
      if listView then
        listView.setSelection(0)
        handler.postDelayed(Runnable{
          run = function()
            local root = service.getRootInActiveWindow()
            if root then
              local nodes = root.findAccessibilityNodeInfosByText("Login & Buat Kunci API")
              if nodes and nodes.size() > 0 then
                nodes.get(0).performAction(64)
              end
            end
          end
        }, 150)
      end
    end
  end)
  provDlg.show()
end

menuDlg = LuaDialog(service)
menuDlg.setTitle(E_KEY .. " Manager API Key")
local menuItems = String{
  E_KEY .. " Login & Buat Kunci API",
  E_INFO .. " Tentang Plugin"
}
menuDlg.setItems(menuItems)
menuDlg.setOnItemClickListener(function(parent, v, position, id)
  if position == 0 then
    menuDlg.dismiss()
    showProviderDialog()
  elseif position == 1 then
    menuDlg.dismiss()
    showAboutDialog()
  end
end)

menuDlg.setNegativeButton("Tutup", function(d)
  this.postSpeak(500, "Created By: SamAditMada.")
  d.dismiss()
end)

menuDlg.show()
return true