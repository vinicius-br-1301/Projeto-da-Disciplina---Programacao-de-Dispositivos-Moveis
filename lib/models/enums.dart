enum StatusEnum {
  ATIVA,
  PAUSADA,
  FINALIZADA;

  static StatusEnum fromJson(String value) {
    return StatusEnum.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => StatusEnum.ATIVA,
    );
  }
}

enum PostItCat {
  LORE,
  QUEST,
  NPC,
  COMBATE,
  LOOT;

  static PostItCat fromJson(String value) {
    return PostItCat.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PostItCat.LORE,
    );
  }
}

enum RoleEnum {
  ADMIN,
  MESTRE,
  JOGADOR;

  static RoleEnum fromJson(String value) {
    return RoleEnum.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => RoleEnum.JOGADOR,
    );
  }
}

enum Dificuldade {
  FACIL,
  MEDIO,
  DIFICIL,
  MORTAL;

  static Dificuldade fromJson(String value) {
    return Dificuldade.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Dificuldade.FACIL,
    );
  }
}
