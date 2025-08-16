enum UserType { pf, pjEmpresa, pjIndividual }

UserType parseUserType(String raw) {
  switch (raw) {
    case 'pf':
      return UserType.pf;
    case 'pj_empresa':
      return UserType.pjEmpresa;
    case 'pj_individual':
      return UserType.pjIndividual;
    default:
      throw ArgumentError('Tipo de usuário inválido: $raw');
  }
}

String userTypeToString(UserType t) {
  switch (t) {
    case UserType.pf:
      return 'pf';
    case UserType.pjEmpresa:
      return 'pj_empresa';
    case UserType.pjIndividual:
      return 'pj_individual';
  }
}
