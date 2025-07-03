local curl = require("cURL")
local zipUrl = "https://kieunhutrung1.github.io/tmp/touch/update.zip"
local zipPath = rootDir() .. "/update.zip"
local extractTo = rootDir()  -- Giải nén ngay tại thư mục root
function downloadZip(url, savePath)
    local file = io.open(savePath, "wb")
    if not file then
        toast("❌ Không thể tạo file!", 5)
        return false
    end
    local c = curl.easy{
        url = url,
        writefunction = function(chunk)
            file:write(chunk)
            return #chunk
        end
    }
    c:setopt(curl.OPT_SSL_VERIFYPEER, false)
    c:setopt(curl.OPT_FOLLOWLOCATION, 1)
    c:setopt(curl.OPT_TIMEOUT, 20)
    local ok, err = pcall(function()
        c:perform()
    end)
    c:close()
    file:close()
    if ok then
        toast("✅ Tải thành công!", 2)
        return true
    else
        toast("❌ Lỗi khi tải: " .. tostring(err), 5)
        return false
    end
end
function unzipFile(zipFile, toFolder)
    local cmd = string.format('unzip -o "%s" -d "%s"', zipFile, toFolder)
    local result = execute(cmd)
    toast("✅ Giải nén thành công!", 3)
end
if downloadZip(zipUrl, zipPath) then
    unzipFile(zipPath, extractTo)
end
