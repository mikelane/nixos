# See: https://github.com/ryantm/agenix
let
  mikelane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9ShMa2C7MjxVm71/df2h6QcLVDONYe8U7P7oFuAt69";
  users = [ mikelane ];

  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFL/7b28YMi3UUGhbbQIU/V2LOoy5uIjBdJ4lFKx26Gz root@nixos";
  systems = [ nixos ];
in
{
  "openai_api_key.age".publicKeys = [ mikelane nixos ];
}
