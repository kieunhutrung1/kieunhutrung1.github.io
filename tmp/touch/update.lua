local url = "https://kieunhutrung1.github.io/tmp/touch/update.zip"
local zipPath = rootDir() .. "/update.zip"
local extractTo = rootDir()
-- 🧾 Hàm kiểm tra file tồn tại
function fileExists(filePath)
  local f = io.open(filePath, "r")
  if f then f:close() return true else return false end
end
-- 📥 Tải file bằng curl
toast("⬇️ Đang tải file...")
local cmd = string.format('curl -k -L "%s" -o "%s"', url, zipPath)
execute(cmd)
-- ✅ Kiểm tra
if fileExists(zipPath) then
  toast("✅ Tải thành công!", 2)
  -- 📦 Giải nén nếu file tồn tại
  toast("🗂️ Đang giải nén...")
  local unzipCmd = string.format('unzip -o "%s" -d "%s"', zipPath, extractTo)
  execute(unzipCmd)
  toast("✅ Giải nén xong!", 2)
else
  toast("❌ Không tìm thấy file sau khi tải!", 5)
end
