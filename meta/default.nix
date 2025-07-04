{ ... }: {
  sshPublicKeys = {
    applin =
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEONXTWVbwRMZJpZ+CJE2n1ELDBjXG39+Ogxdkf1BQcpufLngg0iteB46YcRkZcaErCa+EI2YjkiOrGMTrXfR050tSicG79i+1fjkzqnAe7lA4jDbOjnqn1v3iO8qBPpPr6Jtxg8LMMowGXIi69W36aBzIs73WEW2zN5bsbtCYr0zXBaLaGCfzr2kAzDuiFvPGrQMwlNDYS0EuNklt/RscFzwjRS5sJhi2IteNLbPRMzNYeDBhubgJd1l+tTxWgOo7X80cUjZ9dSytLMd+3ean8qTOC7h4AggUmKLEQ4e86TwyQG8uppeYfYNurI9QdnrMnilQfVC8b47mj3+ohBiYXiVZpvN0g1mgUgHzgg2xnWoqJS46DdKSeSBS0dE8FHOh/iAJPhd7DRk7nZL384uen0WdghUax+32yYj+sp/ofLcHM81sqjtzgUnnfEW+FYeD/KbWrdNz4zuXmFzM60XIlnF2yComBQnvsuEFrC95rYgBbu4qr0FqJFyGIIkEaMs=";
  };

  programs.git = {
    enable = true;
    userName = "Edward Wibowo";
    userEmail = "wibow9770@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "store";
      commit.gpgsign = true;
    };
    signing = { key = "5F7198C07D80B3B6815D687B194285BC07FDC3DA"; };
  };
}
