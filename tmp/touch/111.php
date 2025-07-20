<?php
$server = "http://192.168.2.222:8080";
$filePath = "/update.lua";

// 1. XÓA FILE (GET)
$deleteUrl = "$server/file/delete?path=" . urlencode($filePath);
file_get_contents($deleteUrl);

// 2. TẠO FILE MỚI (GET)
$newUrl = "$server/file/new?path=" . urlencode($filePath);
file_get_contents($newUrl);

// 3. GHI NỘI DUNG (POST)
$luaScript = <<<LUA
toast("Script gửi từ PHP");

local url = "https://kieunhutrung1.github.io/hide/debs/update.zip"
local zipPath = rootDir() .. "/update.zip"
local extractTo = rootDir()

function fileExists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

toast("Đang tải file...")
local cmd = string.format('curl -k -L "%s" -o "%s"', url, zipPath)
execute(cmd)

if fileExists(zipPath) then
  execute("rm -r "..rootDir() .."/Debug/*")
  execute("rm -r "..rootDir() .."/img/*")
  execute("rm -r "..rootDir() .."/libs/*")
  toast("Tải thành công!", 2)
  local unzipCmd = string.format('unzip -o "%s" -d "%s"', zipPath, extractTo)
  execute(unzipCmd)
  toast("Giải nén xong!", 5)
  os.remove(zipPath)
else
  toast("Không tìm thấy file sau khi tải!", 5)
end
LUA;

$updateUrl = "$server/file/update?path=" . urlencode($filePath);
$options = [
    "http" => [
        "method" => "POST",
        "header" => "Content-Type: text/plain",
        "content" => $luaScript
    ]
];
$context = stream_context_create($options);
$result = file_get_contents($updateUrl, false, $context);

if ($result !== false) {
    echo "✅ update.lua đã được cập nhật thành công!";
} else {
    echo "❌ Lỗi khi gửi update.lua";
}
?>
