String createChatId(List<String> ids) {
  if (ids.isEmpty) {
    throw ArgumentError("Participant IDs cannot be empty.");
  }

  ids.sort((a, b) => a.hashCode.compareTo(b.hashCode));
  return ids.join("-");
}
