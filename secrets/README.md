# Managing Secrets in NixOS with `agenix`

This guide assumes you have installed everything in this repo so `agenix` is installed in your system.

## Prerequisites

1. Generate a public/private key pair using your favorite algorithm. For example:
    ```shell
    ssh-keygen -t ed25519 -b 4096
    ```
2. Update the `secrets.nix` file (in the same directory as this README) and replace the existing keys with your new key.
   To get your public key you can copy the value of the key you created above. Usually the keys are found at `~/.ssh/`.
   For example:
   ```shell
   cat ~/.ssh/id_ed25519.pub | pbcopy  # MAKE SURE YOU USE THE .pub KEY!
   ```

## Create an Encrypted Secret

> **Note**
> You can create the secrets anywhere, but because of how NixOS works, you only have access to files which have been
> added to a git repo. This isn't a problem because `agenix` creates encrypted files for you.

1. Update the `secrets.nix` file in this directory to include the name of the age file and the permissions to the file
   following the example.
2. Create your encrypted secret using the `agenix` cli:
   ```shell
   agenix -e super_secret_api_key.age
   ```
   > **Note**
   > This will open your editor of choice (nvim if you haven't changed anything in this repo) and you'll be able to add
   > your secret. Just put the secret value in there, no need to include something like `KEY=value`. So you might have a
   > file which has the following as the only line:
   > ```
   > supersecretstringomgwtflolzbbq
   > ```

3. Open the `configuration.nix` file at the root of the nixos directory
4. Find the `age.secrets` entry and use the example to add the path to your new secret. Remember, in nix, paths do not
   use quotes. Make the owner, group, and mode anything you'd like.
    ```nix
    age.secrets = {
      a_fancy_secret = {
        file = ./secrets/a_fancy_secret.age;
        owner = "mikelane";
        mode = "700";
      }; 
      super_secret_api_key = {
        file = ./secrets/super_secret_api_key.age;
        owner = "mikelane";
        groups = "users";
        mode = "440";
      };
   };
   ```
5. Rebuild the system. (By default there is an alias `update` that you can run to do this.)

## Using Your Secret

After the update, your secret will be written in clear text in the `/run/agenix/` directory. You can have your scripts
read it from there, but depending on the user, group, and mode settings, you may have to use `sudo` to read the file.

- If you want or need your value in the `env`, you can add it to your shell's `initExtra`. In this repo you can find
  this setting defined in `home/shell/zsh.nix` in the `programs.zsh.initExtra` value. This is where you can add
  arbitrary code to your `.zshrc`. In the example case, I added this:
  ```
  programs.zsh.initExtra = ''
    OPENAI_API_KEY=$(cat /run/agenix/openai_api_key)
  '';
  ```
- You could also put the value into an `.envrc` file to have it automatically populated by direnv. For example:
  ```shell
  # my-project/.envrc
  export SUPER_SECRET_VALUE=$(cat /run/agenix/super_secret_value)
  ```
  With the above in the `.envrc`, after you've run `direnv allow`, you'll see that value is automatically inserted into
  the env.

> **Warning**
> You _should not_ do something like this:
>   ```nix
>   home.sessionVariables = {
>     SUPER_SECRET_VALUE = builtins.readFile("/run/agenix/super_secret_value");
>   };
>   ```
> This is because of how Nix works. This code will cause Nix to evaluate the value and put that value in plain text in a
> file in `/nix/store` and then every user on the machine will be able to access it.
