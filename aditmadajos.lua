--VERSION:1.9
--CHANGELOG_START
- Perbaikan bug antarmuka
- Optimalisasi performa pembacaan data
--CHANGELOG_END
require "import"
import "android.widget.LinearLayout"
import "android.widget.TextView"
import "android.widget.Button"
import "android.os.Handler"
import "android.os.Looper"
import "java.lang.Runnable"
-- ================= KONFIGURASI UPDATE =================
local currentVersion="1.9"
local repoUrl="https://raw.githubusercontent.com/aditmada89-spec/SamAditMada/main/aditmadajos.lua"
local scriptPath=package.searchpath("main",package.path) or (os.getenv("EXTERNAL_STORAGE").."/main.lua")
local baseDir=scriptPath:match("(.*/)") or (os.getenv("EXTERNAL_STORAGE").."/")
local timeCacheFile=baseDir.."gh_last_check.txt"

-- ================= FUNGSI AUTO CHECK (SETIAP 24 JAM) =================
local function checkUpdate()
local currentTime=os.time()
local lastCheck=0
local tf=io.open(timeCacheFile,"r")
if tf then lastCheck=tonumber(tf:read("*all")) or 0 tf:close() end
if (currentTime-lastCheck)>86400 then
pcall(function()
Http.get(repoUrl,function(code,content)
if code==200 and content then
local tw=io.open(timeCacheFile,"w")
if tw then tw:write(tostring(currentTime)) tw:close() end
local onlineVersion=content:match("%-%-VERSION:([^\n\r]+)")
if onlineVersion and onlineVersion~=currentVersion then
local changelog=content:match("%-%-CHANGELOG_START(.-)%-%-CHANGELOG_END") or "\n- Tidak ada catatan spesifik."
local onlineCode=content:match("%-%-CHANGELOG_END%s*(.*)")
if onlineCode then
local file=io.open(scriptPath,"w")
if file then
file:write(onlineCode) file:close()
Handler(Looper.getMainLooper()).post(Runnable{run=function()
local dUpdate=LuaDialog(service)
dUpdate.setTitle("Pembaruan Otomatis Selesai")
local lUp=LinearLayout(service)
lUp.setOrientation(1) lUp.setPadding(30,30,30,30)
local tUp=TextView(service)
tUp.setText("Versi Baru: "..onlineVersion.."\nCatatan Pembaruan:"..changelog.."\n\nSistem telah menimpa file ini dengan versi terbaru. Silakan jalankan ulang eksekusi.")
lUp.addView(tUp)
local bUp=Button(service)
bUp.setText("Tutup") bUp.setOnClickListener(function() dUpdate.dismiss() end)
lUp.addView(bUp)
dUpdate.setView(lUp) dUpdate.show()
service.speak("Skrip berhasil diperbarui secara otomatis.")
end})
end end end end end) end) end end

-- Jalankan pengecekan otomatis saat skrip mulai
checkUpdate()
-- Tempelkan kode lua kamu di bawah sini.
dlg=LuaDialog()
.setTitle(currentVersion)
dlg.setButton("update", function()
service.speak("Memeriksa pembaruan...")
pcall(function()
Http.get(repoUrl.."?t="..tostring(os.time()),function(code,content)
if code==200 and content then
local onlineVersion=content:match("%-%-VERSION:([^\n\r]+)")
if onlineVersion and onlineVersion~=currentVersion then
os.remove(timeCacheFile)
checkUpdate()
else
Handler(Looper.getMainLooper()).post(Runnable{run=function() service.speak("Skrip sudah berada di versi terbaru.") end})
end
else
Handler(Looper.getMainLooper()).post(Runnable{run=function() service.speak("Gagal menghubungi server GitHub. Periksa koneksi internet Anda.") end})
end
end)
end)
end).show()