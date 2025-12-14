bool isLink(String text) {
  RegExp urlPattern = RegExp(
    r'^https?:\/\/(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+(?:\/[^\s]*)?$',
  );

  return urlPattern.hasMatch(text);
}
