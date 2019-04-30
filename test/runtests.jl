using Test
import HTTP
using Random
using Base64
using WebDAV


username,password,url =
    if haskey(ENV,"WEBDAV_PASSWORD")
        ENV["WEBDAV_USERNAME"],ENV["WEBDAV_PASSWORD"],ENV["WEBDAV_URL"]
    else
        split(read(expanduser("~/.test_webdav"),String))
    end


userinfo = username * ":" * password;



fname = tempname()
content = randstring(10)
open(fname,"w") do f
    write(f,content)
end

remote_fname = "test_webdev_$(randstring(10)).txt"

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


if isdir(s,"test-dir-julia")
    rm(s,"test-dir-julia")
end
@test isdir(s,"test-dir-julia") == false

mkdir(s,"test-dir-julia")

@test isdir(s,"test-dir-julia")
@test isdir(s,remote_fname) == false

@test isfile(s,"test-dir-julia") == false
@test isfile(s,remote_fname)
