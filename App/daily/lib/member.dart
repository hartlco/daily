class Member {
  final String login;
  final String avatarURL;

  Member(this.login, this.avatarURL) {
    if (login == null) {
      throw new ArgumentError("login of Member cannot be null. "
          "Received: '$login'");
    }

    if (avatarURL == null) {
      throw new ArgumentError("avatarURL of Member cannot be null. "
          "Received: '$login'");
    }
  }
}