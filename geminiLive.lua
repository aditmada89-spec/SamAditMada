--VERSION:1.1
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
local currentVersion="1.1"
local repoUrl="https://raw.githubusercontent.com/aditmada89-spec/SamAditMada/main/geminiLive.lua"
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
require "import"
import "android.app.*"
import "android.content.*"
import "android.widget.*"
import "android.view.*"
import "android.view.accessibility.AccessibilityEvent"
import "android.speech.RecognizerIntent"
import "android.speech.SpeechRecognizer"
import "android.speech.RecognitionListener"
import "android.net.Uri"
import "android.media.MediaPlayer"
import "android.util.Base64"
import "android.graphics.Color"
import "android.graphics.drawable.GradientDrawable"
import "android.os.Looper"
import "android.os.Handler"
import "java.io.*"
import "java.net.URL"
import "java.net.HttpURLConnection"
import "java.lang.Thread"
import "java.lang.Runnable"
import "java.lang.String"
import "java.lang.reflect.Array"
import "java.nio.ByteBuffer"
import "java.nio.ByteOrder"
import "org.json.JSONObject"
local mainHandler = Handler(Looper.getMainLooper())
local function runOnUiThread(action)
mainHandler.post(Runnable{ run = action })
end
local function restoreFocusToView(targetView)
if targetView then
mainHandler.postDelayed(Runnable{
run = function()
pcall(function()
targetView.setFocusable(true)
targetView.setFocusableInTouchMode(true)
targetView.requestFocus()
targetView.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
end)
end
}, 120)
end
end
local function createDialogBackground()
local gd = GradientDrawable()
gd.setColor(Color.parseColor("#FFFFFF"))
gd.setCornerRadius(28)
return gd
end
local prefs = service.getSharedPreferences("gemini_live_chat_prefs", Context.MODE_PRIVATE)
local tempAudioPath = "/sdcard/gemini_live_reply.wav"
local tempPcmPath = "/sdcard/gemini_live_reply.pcm"
local LOCKED_VOICE = "Capella"
local lastAiAnswerText = ""
local chatHistory = {}
local function resetChatHistory()
chatHistory = {}
lastAiAnswerText = ""
end
local BUILTIN_API_KEYS = {
"AIzaSyDcNBbjyvXypfe-sf9syyDTDcTM6ObMyd8",
"AIzaSyD_pbDte3sq3LHJoQp_GMfTGVIdpRLqOH8",
"AIzaSyAYU-btIv0zD6cTmuv_b3bdoDdtN37lBkA",
"AIzaSyAvJw9T45PZ5Td_AMpc-wR_MO7yjUP_jyM",
"AIzaSyCvbKoHtBwbUxiwiy1GTn9B0YFUBJUIOHM",
"AIzaSyDAvDwIT60D3zF8UhW2U0sDyGre0L_M2F0",
"AIzaSyDuqe3KS_paTcwBOB81Dugv56T9XEupkj4",
"AIzaSyBrs1wco0nI9hQbpFulPtcc9bkNv2UV4d8",
"AIzaSyAdtSSrY-2qDiJYOp0YMjxSB0aOHf3tRYo",
"AIzaSyClYv_Ad6UKDbmrWfi-p_0DxRhPf7SyDuM",
"AIzaSyBqxlmdCe_wkrNEdGeAXBJvPxOsNEAt-IU",
"AIzaSyCeIfS4xk7jY4nTqHH9u3b2QHSm11__ZKs",
"AIzaSyB6HYTFg4bKOBNHjj-njNR22BMF2X7ZCTA",
"AIzaSyDfczqhYutPUP809DreCR4WVmeKECJJoN8",
"AIzaSyB1CUWg4xU2wxb4yg7Mf9SBmD-DxHb_IO4",
"AIzaSyB1Msj-hbICW-jvU2TPU8aU2yWHWnIkXCk",
"AIzaSyCKUUuks5vQClio5jmn4aZWTQyFEk4pNCQ",
"AIzaSyAfL4Kcg2eqfo39R451BZK_sin8NS6lBeQ",
"AIzaSyDCEZkxyg-Yiu7peZpTt9j77bq4oAI2v2w",
"AIzaSyAYc_NaDCE6MOYn-gMyXyfY_hHXccT9sKc",
"AIzaSyBo_ToakjT-BML-HREgnG3ieewh3yRZkM8",
"AIzaSyAtkrGBJh0AA7-9hSH1IG4gq_r_X5PDmMY",
"AIzaSyAYRHaGa05BLi7W7L4L_11E0k9lJpRHyrE",
"AIzaSyDSixx94GM3Ljqq_ZwJZC7SQtfiqYnp5Gg",
"AIzaSyC460D_XUTVISJfSLBgJtmz87MtJbQt4cU",
"AIzaSyA5MEme6Eu8P9tnRdG0GfLz_LkFUCfMoEw",
"AIzaSyBriBfJxLBnzGj7H_B-Jyd8CO67yqH1NpQ",
"AIzaSyAplwNaSAUCB41SglqWPNylkrIJl6V1r4s",
"AIzaSyCKIdfxxI1IqWPGTN1D29kjKRl_WFspf04",
"AIzaSyDi6wUPXk_GF4l55dbNnd8lTB3SNjMjP5A",
"AIzaSyCgInY0JgLNRVcU2-vPCDzZhMhBM4vg9XU",
"AIzaSyBl_8erz__8WZwCrFeAlRqtyrvgvkQprcc",
"AIzaSyAiyAZZCun5G83rNaLNhN0icJHtMnn2z6s",
"AIzaSyBza14koBBpzt-lClwkODqEV7ys9Lf3jYU",
"AIzaSyAMsVHc72Uvz-OqbCZOkFVUIAWueA_ZPwQ",
"AIzaSyBJ94f_WpIvI92cthHDepKFI8l8te2Oz08",
"AIzaSyAKCwpqDZ-y7YTGpsWkK7AklifJnIP3SBc",
"AIzaSyDAm_CnhbhtxiqG1mS0KpaDSSVL33Qa7fU",
"AIzaSyBJPCaBfJG-cOKuICxtGsj8wf7F9CE7TbY",
"AIzaSyCZGiDzSgo5FXeI8k5KYaHVlrbtn3zsAHQ"
}
local function getSavedApiKey()
return prefs.getString("user_gemini_api_key", "")
end
local function saveApiKey(key)
local editor = prefs.edit()
editor.putString("user_gemini_api_key", tostring(key))
editor.apply()
end
local function getParsedApiKeyList()
local keys = {}
local seen = {}
for _, item in ipairs(BUILTIN_API_KEYS) do
local k = item:gsub("%s+", "")
if k ~= "" and not seen[k] then
seen[k] = true
table.insert(keys, k)
end
end
local raw = getSavedApiKey()
for item in raw:gmatch("[^\r\n,;]+") do
local k = item:gsub("%s+", "")
if k ~= "" and not seen[k] then
seen[k] = true
table.insert(keys, k)
end
end
return keys
end
local globalAudioPlayer = nil
local function stopAudioPlayback()
pcall(function()
if globalAudioPlayer then
if globalAudioPlayer.isPlaying() then globalAudioPlayer.stop() end
globalAudioPlayer.release()
globalAudioPlayer = nil
end
end)
end
local function playAudioFile(filePath, onFinishCallback)
pcall(function()
stopAudioPlayback()
globalAudioPlayer = MediaPlayer()
globalAudioPlayer.setDataSource(filePath)
globalAudioPlayer.prepare()
globalAudioPlayer.start()
globalAudioPlayer.setOnCompletionListener(luajava.createProxy("android.media.MediaPlayer$OnCompletionListener", {
onCompletion = function(mp)
stopAudioPlayback()
if onFinishCallback then onFinishCallback() end
end
}))
end)
end
local function encodePcmToWav(pcmFile, outputFile, sampleRate, channels)
sampleRate = sampleRate or 24000
channels = channels or 1
local bitsPerSample = 16
local pcmDataLen = pcmFile.length()
local totalDataLen = pcmDataLen + 36
local byteRate = sampleRate * channels * (bitsPerSample / 8)
local blockAlign = channels * (bitsPerSample / 8)
local header = ByteBuffer.allocate(44)
header.order(ByteOrder.LITTLE_ENDIAN)
header.put(String("RIFF").getBytes())
header.putInt(totalDataLen)
header.put(String("WAVE").getBytes())
header.put(String("fmt ").getBytes())
header.putInt(16)
header.putShort(1)
header.putShort(channels)
header.putInt(sampleRate)
header.putInt(byteRate)
header.putShort(blockAlign)
header.putShort(bitsPerSample)
header.put(String("data").getBytes())
header.putInt(pcmDataLen)
local fos = FileOutputStream(outputFile)
fos.write(header.array())
local fis = FileInputStream(pcmFile)
local buffer = Array.newInstance(Byte.TYPE, 4096)
local bytesRead = fis.read(buffer)
while bytesRead > 0 do
fos.write(buffer, 0, bytesRead)
bytesRead = fis.read(buffer)
end
fis.close()
fos.flush()
fos.close()
end
local function copyToClipboard(textToCopy)
pcall(function()
local clipboard = service.getSystemService(Context.CLIPBOARD_SERVICE)
local clip = ClipData.newPlainText("Jawaban Gemini", textToCopy)
clipboard.setPrimaryClip(clip)
service.speak("Teks jawaban berhasil disalin ke papan klip.")
end)
end
local function escapeJson(s)
return tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')
end
local mainDialog = nil
local isProcessing = false
local promptVoiceInput = nil
local function askGeminiLive(userInput)
if isProcessing then
service.speak("Harap tunggu, proses sebelumnya masih berjalan.")
return
end
local apiKeys = getParsedApiKeyList()
if #apiKeys == 0 then
service.speak("Kunci API belum diatur. Silakan masukkan kunci API Anda di menu Konfigurasi API.")
return
end
local lowerInput = userInput:lower():gsub("^%s*(.-)%s*$", "%1")
if lowerInput == "berhenti" or lowerInput == "selesai" or lowerInput == "stop" or lowerInput == "cukup" or lowerInput == "keluar" then
resetChatHistory()
service.speak("Percakapan diakhiri.")
return
end
isProcessing = true
service.speak("Gemini sedang berpikir...")
table.insert(chatHistory, string.format('{"role":"user","parts":[{"text":"%s"}]}', escapeJson(userInput)))
Thread(Runnable{
run = function()
local currentDateStr = os.date("%Y-%m-%d")
local systemPromptText = "Kamu adalah asisten percakapan suara Gemini Live yang cerdas dan komunikatif. Tanggal hari ini adalah " .. currentDateStr .. ". Jawab pertanyaan secara akurat, ramah, dan padat layaknya obrolan lisan 1 sampai 3 kalimat saja. Dilarang mengulang pertanyaan pengguna."
local chatModels = {
"gemini-2.5-flash-lite",
"gemini-2.5-flash",
"gemini-flash-latest"
}
local contentsJson = table.concat(chatHistory, ",")
local aiAnswerText = nil
local lastErrorCode = ""
for _, curKey in ipairs(apiKeys) do
if aiAnswerText then break end
for _, cMod in ipairs(chatModels) do
if aiAnswerText then break end
for retry = 1, 2 do
if aiAnswerText then break end
pcall(function()
local targetUrl = "https://generativelanguage.googleapis.com/v1beta/models/" .. cMod .. ":generateContent?key=" .. curKey
local conn = URL(targetUrl).openConnection()
conn.setRequestMethod("POST")
conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8")
conn.setDoOutput(true)
conn.setConnectTimeout(15000)
conn.setReadTimeout(20000)
local payloadChat = string.format('{"systemInstruction":{"parts":[{"text":"%s"}]},"contents":[%s]}', escapeJson(systemPromptText), contentsJson)
local writer = OutputStreamWriter(conn.getOutputStream(), "UTF-8")
writer.write(payloadChat)
writer.flush()
writer.close()
local respCode = conn.getResponseCode()
if respCode == 200 then
local reader = BufferedReader(InputStreamReader(conn.getInputStream(), "UTF-8"))
local sb = {}
local line = reader.readLine()
while line ~= nil do table.insert(sb, tostring(line)); line = reader.readLine() end
reader.close()
local jsonResp = JSONObject(table.concat(sb, "\n"))
local candParts = jsonResp.getJSONArray("candidates").getJSONObject(0).getJSONObject("content").getJSONArray("parts")
local collectedText = {}
for pIdx = 0, candParts.length() - 1 do
local partObj = candParts.getJSONObject(pIdx)
if partObj.has("text") then
table.insert(collectedText, partObj.getString("text"))
end
end
if #collectedText > 0 then
aiAnswerText = table.concat(collectedText, " ")
end
else
lastErrorCode = tostring(respCode)
end
end)
if lastErrorCode == "503" and not aiAnswerText then
Thread.sleep(1200)
else
break
end
end
end
end
if not aiAnswerText or aiAnswerText:gsub("%s+", "") == "" then
isProcessing = false
table.remove(chatHistory)
runOnUiThread(function()
if lastErrorCode == "503" then
service.speak("Server Google sedang sangat sibuk (Error 503). Silakan coba bicara lagi beberapa detik lagi.")
elseif lastErrorCode == "429" then
service.speak("Batas kuota harian API Anda tercapai (Error 429).")
else
service.speak("Gagal tersambung (" .. lastErrorCode .. "). Periksa internet atau Kunci API Anda.")
end
end)
return
end
local cleanAnswer = aiAnswerText:gsub("^%s*(.-)%s*$", "%1")
lastAiAnswerText = cleanAnswer
table.insert(chatHistory, string.format('{"role":"model","parts":[{"text":"%s"}]}', escapeJson(cleanAnswer)))
while #chatHistory > 20 do
table.remove(chatHistory, 1)
end
local ttsSuccess = false
local audioTextToSpeak = cleanAnswer
local ttsModels = {
"gemini-2.5-flash-preview-tts",
"gemini-3.1-flash-tts-preview"
}
for _, curKey in ipairs(apiKeys) do
if ttsSuccess then break end
for _, ttsMod in ipairs(ttsModels) do
if ttsSuccess then break end
pcall(function()
local targetTtsUrl = "https://generativelanguage.googleapis.com/v1beta/models/" .. ttsMod .. ":generateContent?key=" .. curKey
local connTTS = URL(targetTtsUrl).openConnection()
connTTS.setRequestMethod("POST")
connTTS.setRequestProperty("Content-Type", "application/json; charset=UTF-8")
connTTS.setDoOutput(true)
connTTS.setConnectTimeout(15000)
connTTS.setReadTimeout(30000)
local payloadTTS = '{"contents":[{"parts":[{"text":"' .. escapeJson(audioTextToSpeak) .. '"}]}],"generationConfig":{"responseModalities":["AUDIO"],"speechConfig":{"voiceConfig":{"prebuiltVoiceConfig":{"voiceName":"' .. LOCKED_VOICE .. '"}}}}}'
local writer = OutputStreamWriter(connTTS.getOutputStream(), "UTF-8")
writer.write(payloadTTS)
writer.flush()
writer.close()
if connTTS.getResponseCode() == 200 then
local reader = BufferedReader(InputStreamReader(connTTS.getInputStream(), "UTF-8"))
local sb = {}
local line = reader.readLine()
while line ~= nil do table.insert(sb, tostring(line)); line = reader.readLine() end
reader.close()
local resText = table.concat(sb, "\n")
local base64Data = resText:match('"data"%s*:%s*"([A-Za-z0-9+/=]+)"')
local mimeType = resText:match('"mimeType"%s*:%s*"([^"]+)"') or ""
if base64Data and #base64Data > 100 then
local audioBytes = Base64.decode(base64Data, Base64.DEFAULT)
local pcmLen = Array.getLength(audioBytes)
local pcmStart = (base64Data:sub(1, 5) == "UklGR" or mimeType:lower():find("wav")) and (pcmLen > 44 and 44 or 0) or 0
local pcmFile = File(tempPcmPath)
local fos = FileOutputStream(pcmFile)
fos.write(audioBytes, pcmStart, pcmLen - pcmStart)
fos.flush()
fos.close()
local wavOut = File(tempAudioPath)
encodePcmToWav(pcmFile, wavOut, 24000, 1)
pcall(function() pcmFile.delete() end)
ttsSuccess = true
runOnUiThread(function()
playAudioFile(tempAudioPath, function()
promptVoiceInput()
end)
end)
end
end
end)
end
end
isProcessing = false
if not ttsSuccess then
runOnUiThread(function()
service.speak(cleanAnswer)
mainHandler.postDelayed(Runnable{
run = function()
promptVoiceInput()
end
}, 3000)
end)
end
end
}).start()
end
promptVoiceInput = function()
local apiKeys = getParsedApiKeyList()
if #apiKeys == 0 then
service.speak("Kunci API belum diatur. Silakan atur terlebih dahulu di menu Konfigurasi API.")
return
end
local inputDialog = Dialog(service)
inputDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
local root = LinearLayout(service)
root.setOrientation(LinearLayout.VERTICAL)
root.setPadding(40, 40, 40, 40)
root.setBackground(createDialogBackground())
local titleText = TextView(service)
titleText.setText("Mulai Percakapan (Capella)")
titleText.setTextSize(18)
titleText.setTextColor(Color.parseColor("#212121"))
titleText.setPadding(0, 0, 0, 15)
root.addView(titleText)
local infoText = TextView(service)
infoText.setText("Tuliskan pertanyaan Anda atau tekan Rekam Suara:")
infoText.setTextColor(Color.parseColor("#555555"))
infoText.setTextSize(14)
infoText.setPadding(0, 0, 0, 10)
root.addView(infoText)
local editInput = EditText(service)
editInput.setHint("Tulis pertanyaan di sini...")
editInput.setMinLines(3)
editInput.setGravity(Gravity.TOP | Gravity.START)
root.addView(editInput)
local btnMic = Button(service)
btnMic.setText("Rekam Suara (Microphone)")
local lpMic = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpMic.setMargins(0, 10, 0, 10)
btnMic.setLayoutParams(lpMic)
btnMic.setOnClickListener(View.OnClickListener{
onClick = function(v)
if not SpeechRecognizer.isRecognitionAvailable(service) then
service.speak("Pengenal suara Android tidak tersedia.")
return
end
service.speak("Mendengarkan, silakan bicara...")
local recognizer = SpeechRecognizer.createSpeechRecognizer(service)
local intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "id-ID")
intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, service.getPackageName())
recognizer.setRecognitionListener(luajava.createProxy("android.speech.RecognitionListener", {
onReadyForSpeech = function(params) end,
onBeginningOfSpeech = function() end,
onRmsChanged = function(rmsdB) end,
onBufferReceived = function(buffer) end,
onEndOfSpeech = function() end,
onError = function(error)
pcall(function() recognizer.destroy() end)
service.speak("Suara tidak terdeteksi, silakan coba lagi.")
end,
onResults = function(results)
pcall(function() recognizer.destroy() end)
if results ~= nil then
local matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
if matches and matches.size() > 0 then
local spokenText = matches.get(0)
runOnUiThread(function()
editInput.setText(spokenText)
inputDialog.dismiss()
askGeminiLive(spokenText)
end)
end
end
end,
onPartialResults = function(partialResults) end,
onEvent = function(eventType, params) end
}))
recognizer.startListening(intent)
end
})
root.addView(btnMic)
if lastAiAnswerText ~= "" then
local btnSalin = Button(service)
btnSalin.setText("Salin Teks Jawaban")
local lpSalin = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpSalin.setMargins(0, 0, 0, 10)
btnSalin.setLayoutParams(lpSalin)
btnSalin.setOnClickListener(View.OnClickListener{
onClick = function(v)
copyToClipboard(lastAiAnswerText)
end
})
root.addView(btnSalin)
end
local actionLayout = LinearLayout(service)
actionLayout.setOrientation(LinearLayout.HORIZONTAL)
actionLayout.setGravity(Gravity.END)
actionLayout.setPadding(0, 10, 0, 0)
local btnKirim = Button(service)
btnKirim.setText("Kirim")
btnKirim.setOnClickListener(View.OnClickListener{
onClick = function(v)
local txt = tostring(editInput.getText()):gsub("^%s*(.-)%s*$", "%1")
if txt == "" then
pcall(function() service.speak("Pertanyaan belum diisi.") end)
return
end
inputDialog.dismiss()
askGeminiLive(txt)
end
})
actionLayout.addView(btnKirim)
local btnBatal = Button(service)
btnBatal.setText("Batal")
btnBatal.setOnClickListener(View.OnClickListener{
onClick = function(v)
resetChatHistory()
inputDialog.dismiss()
end
})
actionLayout.addView(btnBatal)
root.addView(actionLayout)
inputDialog.setContentView(root)
local win = inputDialog.getWindow()
win.setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
win.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE | WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE)
inputDialog.show()
mainHandler.postDelayed(Runnable{
run = function()
pcall(function()
btnMic.requestFocus()
btnMic.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
end)
end
}, 150)
end
local function showApiKeyDialog(triggerView)
local kDialog = Dialog(service)
kDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
local root = LinearLayout(service)
root.setOrientation(LinearLayout.VERTICAL)
root.setPadding(40, 40, 40, 40)
root.setBackground(createDialogBackground())
local titleText = TextView(service)
titleText.setText("Konfigurasi API Gemini")
titleText.setTextSize(18)
titleText.setTextColor(Color.parseColor("#212121"))
titleText.setPadding(0, 0, 0, 15)
root.addView(titleText)
local kScroll = ScrollView(service)
local kParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1.0)
kScroll.setLayoutParams(kParams)
local kContainer = LinearLayout(service)
kContainer.setOrientation(LinearLayout.VERTICAL)
local btnGetApiKey = Button(service)
btnGetApiKey.setText("Ambil API Key Baru (Google AI Studio)")
local lpGetApi = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpGetApi.setMargins(0, 0, 0, 10)
btnGetApiKey.setLayoutParams(lpGetApi)
btnGetApiKey.setOnClickListener(View.OnClickListener{
onClick = function(v)
pcall(function() kDialog.dismiss() end)
pcall(function() if mainDialog then mainDialog.dismiss() end end)
stopAudioPlayback()
local uri = Uri.parse("https://aistudio.google.com/app/apikey")
local intent = Intent(Intent.ACTION_VIEW, uri)
intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
service.startActivity(intent)
end
})
kContainer.addView(btnGetApiKey)
local infoText = TextView(service)
infoText.setText("Masukkan Google AI Studio API Key Cadangan Pribadi (Opsional, pisahkan koma):")
infoText.setTextColor(Color.parseColor("#1565C0"))
infoText.setTextSize(13)
infoText.setPadding(0, 5, 0, 5)
kContainer.addView(infoText)
local editKey = EditText(service)
editKey.setHint("AIzaSy... (Pisahkan baris baru / koma)")
editKey.setText(getSavedApiKey())
editKey.setMinLines(3)
editKey.setGravity(Gravity.TOP | Gravity.START)
kContainer.addView(editKey)
local btnConnectUserKey = Button(service)
btnConnectUserKey.setText("Uji Koneksi Kunci API")
local lpConnect = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpConnect.setMargins(0, 10, 0, 10)
btnConnectUserKey.setLayoutParams(lpConnect)
btnConnectUserKey.setOnClickListener(View.OnClickListener{
onClick = function(v)
local rawInput = tostring(editKey.getText())
local tempKeys = {}
for item in rawInput:gmatch("[^\r\n,;]+") do
local k = item:gsub("%s+", "")
if k ~= "" then table.insert(tempKeys, k) end
end
if #tempKeys == 0 then
tempKeys = BUILTIN_API_KEYS
end
service.speak("Sedang menguji koneksi kunci API...")
Thread(Runnable{
run = function()
local connectedCount = 0
for idx, testKey in ipairs(tempKeys) do
if idx > 3 then break end
pcall(function()
local conn = URL("https://generativelanguage.googleapis.com/v1beta/models?key=" .. testKey).openConnection()
conn.setRequestMethod("GET")
conn.setConnectTimeout(8000)
conn.setReadTimeout(8000)
if conn.getResponseCode() == 200 then
connectedCount = connectedCount + 1
end
end)
end
runOnUiThread(function()
if connectedCount > 0 then
service.speak("Kunci API valid dan berhasil terhubung ke server Google.")
else
service.speak("Kunci API gagal terhubung. Periksa kembali kunci API Anda.")
end
end)
end
}).start()
end
})
kContainer.addView(btnConnectUserKey)
local btnSaveAllConfig = Button(service)
btnSaveAllConfig.setText("Simpan API Key")
local lpSaveAll = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpSaveAll.setMargins(0, 10, 0, 10)
btnSaveAllConfig.setLayoutParams(lpSaveAll)
btnSaveAllConfig.setOnClickListener(View.OnClickListener{
onClick = function(v)
local val = tostring(editKey.getText())
saveApiKey(val)
service.speak("Kunci API berhasil disimpan.")
kDialog.dismiss()
end
})
kContainer.addView(btnSaveAllConfig)
kScroll.addView(kContainer)
root.addView(kScroll)
local actionLayout = LinearLayout(service)
actionLayout.setOrientation(LinearLayout.HORIZONTAL)
actionLayout.setGravity(Gravity.END)
actionLayout.setPadding(0, 15, 0, 0)
local btnTutup = Button(service)
btnTutup.setText("Tutup")
btnTutup.setOnClickListener(View.OnClickListener{
onClick = function(v) kDialog.dismiss() end
})
actionLayout.addView(btnTutup)
root.addView(actionLayout)
kDialog.setContentView(root)
local win = kDialog.getWindow()
win.setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
win.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
kDialog.setOnDismissListener(DialogInterface.OnDismissListener{
onDismiss = function(dialog) restoreFocusToView(triggerView) end
})
kDialog.show()
end
local function showAboutPluginDialog(triggerView)
local aDialog = Dialog(service)
aDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
local root = LinearLayout(service)
root.setOrientation(LinearLayout.VERTICAL)
root.setPadding(40, 40, 40, 40)
root.setBackground(createDialogBackground())
local titleText = TextView(service)
titleText.setText("Tentang Plugin Gemini Live Audio Chat")
titleText.setTextSize(18)
titleText.setTextColor(Color.parseColor("#212121"))
titleText.setPadding(0, 0, 0, 15)
root.addView(titleText)
local aScroll = ScrollView(service)
local aParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1.0)
aScroll.setLayoutParams(aParams)
local aContainer = LinearLayout(service)
aContainer.setOrientation(LinearLayout.VERTICAL)
local descText = TextView(service)
descText.setText("Selamat datang di plugin pengusir sepi paling canggih sejagat raya! Kalau Anda bosan ngobrol sama cicak di dinding atau curhat sama kipas angin yang cuma bisa geleng-geleng kepala, alat ini adalah penyelamat hidup Anda.\n\n" ..
"FUNGSI DAN KEGUNAAN:\n" ..
"Alat ini bertugas sebagai teman ngobrol dua arah real-time tanpa ribet. Anda tinggal bicara, dia akan berpikir secepat kilat dan langsung menjawab layaknya sahabat karib yang suaranya ceria, renyah, dan bersemangat!\n\n" ..
"CARA KERJA ALAT:\n" ..
"1. Tekan tombol bicara atau rekam suara, lalu sampaikan unek-unek atau pertanyaan Anda.\n" ..
"2. Suara Anda disulap jadi teks dan dikirim langsung ke otak Google Gemini yang super encer.\n" ..
"3. Gemini menyusun jawaban yang padat, cerdas, komunikatif, dan anti-bertele-tele (maksimal 3 kalimat).\n" ..
"4. Jawabannya disulap kembali menjadi berkas suara asli karakter Capella langsung dari server Google dan diputar seketika.\n" ..
"5. Setelah dia selesai ngomong, mikrofon otomatis kebuka lagi. Kalau sudah lelah berdebat dengannya, cukup tekan Batal pada jendela percakapan.\n\n" ..
"PERINGATAN DAN PENJELASAN SUARA:\n" ..
"Jika suatu saat suara merdu Capella mendadak bisu dan berganti ke suara robot TTS pembaca layar HP Anda, jangan buru-buru banting ponsel Anda! Hal itu terjadi karena:\n" ..
"- Server suara audio Google sedang kehabisan kuota gratis harian/menit (Rate Limit 429).\n" ..
"- Server Google sedang mengalami lonjakan antrean padat di pusat data (Error 503 Server Overload).\n" ..
"- Sinyal internet Anda sedang tersendat saat mengunduh data audio mentah.\n" ..
"Pada kondisi tersebut, plugin secara cerdas langsung mengalihkan suaranya ke mesin TTS lokal HP Anda agar percakapan tetap berjalan lancar tanpa terputus sama sekali!\n\n" ..
"Info Penting: Masih Tahap Uji Coba (Beta): Mainan sakti ini statusnya masih dalam tahap pengujian untuk melihat ketahanan sistem dan server. Jadi harap maklum jika sesekali responnya agak unik atau ada kendala kecil. Langsung Pakai (Tanpa Perlu Kunci API di Awal): Saat pertama kali memasang, Anda TIDAK PERLU memasukkan atau mengatur kunci API apa pun. Plugin ini sudah ditanamkan kunci API bawaan yang langsung aktif. Begitu dipasang, tinggal klik Mulai Percakapan / Bicara dan langsung bisa diajak ngobrol santai. Sistem Pergantian Otomatis: Kunci bawaan di dalamnya bekerja secara estafet. Kalau kunci yang sedang dipakai terkena limit kuota atau server sedang padat, sistem akan otomatis beralih ke kunci cadangan di belakang layar. Kapan Perlu Masukkan Kunci API Sendiri? Anda HANYA perlu mengisi kunci API pribadi di menu Konfigurasi API Key jika: Muncul peringatan bahwa seluruh kuota kunci bawaan sudah habis total. Alat berhenti merespons atau gagal tersambung sama sekali. Catatan Soal Suara: Jika suara Capella mendadak berganti ke suara robot TTS pembaca layar HP Anda, jangan panik! Itu tanda server audio sedang penuh, jadi sistem otomatis mengalihkan suara ke mesin lokal HP agar obrolan tetap bisa berlanjut. Selamat mencoba, selamat menguji coba mainan baru ini, dan selamat mengobrol.\n\n" ..
"Mainan sederhana ini, dirakit oleh:\nSamAditMada.")
descText.setTextColor(Color.parseColor("#424242"))
descText.setTextSize(14)
descText.setPadding(0, 0, 0, 15)
aContainer.addView(descText)
local btnWa = Button(service)
btnWa.setText("Hubungi Pengembang via WhatsApp")
local lpWa = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpWa.setMargins(0, 0, 0, 10)
btnWa.setLayoutParams(lpWa)
btnWa.setOnClickListener(View.OnClickListener{
onClick = function(v)
pcall(function() aDialog.dismiss() end)
pcall(function() if mainDialog then mainDialog.dismiss() end end)
stopAudioPlayback()
pcall(function()
local uri = Uri.parse("https://wa.me/6282228197405")
local intent = Intent(Intent.ACTION_VIEW, uri)
intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
service.startActivity(intent)
end)
end
})
aContainer.addView(btnWa)
local btnTg = Button(service)
btnTg.setText("Gabung Channel Telegram Ekstensi Indonesia")
local lpTg = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpTg.setMargins(0, 0, 0, 15)
btnTg.setLayoutParams(lpTg)
btnTg.setOnClickListener(View.OnClickListener{
onClick = function(v)
pcall(function() aDialog.dismiss() end)
pcall(function() if mainDialog then mainDialog.dismiss() end end)
stopAudioPlayback()
pcall(function()
local uri = Uri.parse("https://t.me/ekstensi_indonesia")
local intent = Intent(Intent.ACTION_VIEW, uri)
intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
service.startActivity(intent)
end)
end
})
aContainer.addView(btnTg)
aScroll.addView(aContainer)
root.addView(aScroll)
local actionLayout = LinearLayout(service)
actionLayout.setOrientation(LinearLayout.HORIZONTAL)
actionLayout.setGravity(Gravity.END)
actionLayout.setPadding(0, 15, 0, 0)
local btnTutupAbout = Button(service)
btnTutupAbout.setText("Tutup")
btnTutupAbout.setOnClickListener(View.OnClickListener{
onClick = function(v) aDialog.dismiss() end
})
actionLayout.addView(btnTutupAbout)
root.addView(actionLayout)
aDialog.setContentView(root)
local win = aDialog.getWindow()
win.setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
win.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
aDialog.setOnDismissListener(DialogInterface.OnDismissListener{
onDismiss = function(dialog) restoreFocusToView(triggerView) end
})
aDialog.show()
end
mainDialog = Dialog(service)
mainDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
local mainRoot = LinearLayout(service)
mainRoot.setOrientation(LinearLayout.VERTICAL)
mainRoot.setPadding(35, 35, 35, 35)
mainRoot.setBackground(createDialogBackground())
local txtTitle = TextView(service)
txtTitle.setText("Gemini Live Audio Chat")
txtTitle.setTextSize(18)
txtTitle.setTextColor(Color.parseColor("#212121"))
txtTitle.setPadding(0, 0, 0, 15)
mainRoot.addView(txtTitle)
local btnStartTalk = Button(service)
btnStartTalk.setText("Mulai Percakapan / Bicara")
local lpStart = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpStart.setMargins(0, 5, 0, 10)
btnStartTalk.setLayoutParams(lpStart)
btnStartTalk.setOnClickListener(View.OnClickListener{
onClick = function(v)
stopAudioPlayback()
mainDialog.dismiss()
resetChatHistory()
promptVoiceInput()
end
})
mainRoot.addView(btnStartTalk)
local btnOpenKeys = Button(service)
btnOpenKeys.setText("Konfigurasi API Key")
local lpKeys = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpKeys.setMargins(0, 0, 0, 10)
btnOpenKeys.setLayoutParams(lpKeys)
btnOpenKeys.setOnClickListener(View.OnClickListener{
onClick = function(v)
showApiKeyDialog(btnOpenKeys)
end
})
mainRoot.addView(btnOpenKeys)
local btnOpenAbout = Button(service)
btnOpenAbout.setText("Tentang Plugin")
local lpAbout = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
lpAbout.setMargins(0, 0, 0, 10)
btnOpenAbout.setLayoutParams(lpAbout)
btnOpenAbout.setOnClickListener(View.OnClickListener{
onClick = function(v)
showAboutPluginDialog(btnOpenAbout)
end
})
mainRoot.addView(btnOpenAbout)
local btnTutupApp = Button(service)
btnTutupApp.setText("Keluar")
local lpClose = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
btnTutupApp.setLayoutParams(lpClose)
btnTutupApp.setOnClickListener(View.OnClickListener{
onClick = function(v)
stopAudioPlayback()
this.postSpeak(500,"Presented By: SamAditMada.")
mainDialog.dismiss()
end
})
mainRoot.addView(btnTutupApp)
mainDialog.setContentView(mainRoot)
local win = mainDialog.getWindow()
win.setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
win.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
mainDialog.show()
mainHandler.postDelayed(Runnable{
run = function()
pcall(function()
btnStartTalk.requestFocus()
btnStartTalk.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
end)
end
}, 150)
return true