{ user, ... }: {
  imports = [
    ../system/android
  ];

  user.userName = user;

  home-manager = {
    users.${user} = { ... }: {
      imports = [
        ../home/influx
        ../home/mud
        ../home/neovim
        ../home/shell
      ];
    };
  };
}
