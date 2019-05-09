using Test
import HTTP
using Random
using Base64
using WebDAV


# username,password,url =
#     if haskey(ENV,"WEBDAV_PASSWORD")
#         ENV["WEBDAV_USERNAME"],ENV["WEBDAV_PASSWORD"],ENV["WEBDAV_URL"]
#     else
#         split(read(expanduser("~/.test_webdav"),String))
#     end


username = "user1"
password = "user1pw"
url = "http://localhost:8003"

userinfo = username * ":" * password;


@testset "WebDAV" begin

fname = tempname()
content = randstring(10)
open(fname,"w") do f
    write(f,content)
end

remote_fname = "test_webdav_$(randstring(10)).txt"
remote_dirname = "test_webdav_dir_$(randstring(10))"

local_fname = tempname()

f = open(fname,"r")
r = HTTP.request("PUT", url * "/" * remote_fname, [("Authorization", "Basic $(base64encode(userinfo))")], f);
close(f)




s = WebDAV.Server(url,username,password);
r = upload(s, fname, remote_fname)
r = download(s, remote_fname)
@test read(r,String) == content


download(s, remote_fname,local_fname)
@test read(local_fname,String) == content


open(s, remote_fname,"r") do io
    @test read(io,String) == content
end


open(s, remote_fname,"w") do io
    write(io,"blabla")
end
f = open(s, remote_fname,"r")
@test read(f,String) == "blabla"


if isdir(s,remote_dirname)
    rm(s,remote_dirname)
end
@test isdir(s,remote_dirname) == false

mkdir(s,remote_dirname)

@test isdir(s,remote_dirname)
@test isdir(s,remote_fname) == false

@test isfile(s,remote_dirname) == false
@test isfile(s,remote_fname)

@test length(readdir(s,remote_dirname)) == 1

rm(s,remote_dirname)
rm(s,remote_fname)

#broken on nginx
#@test isfile(s,"does_not_exists")
end
