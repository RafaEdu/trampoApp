enum UserType {
  // PF
  pfAutonoma,
  pfComCnpj,

  // PJ
  pjContratante,
  pjPrestadora,
}

UserType parseUserType(String raw) {
  switch (raw) {
    case 'pf_autonoma':
      return UserType.pfAutonoma;
    case 'pf_com_cnpj':
      return UserType.pfComCnpj;
    case 'pj_contratante':
      return UserType.pjContratante;
    case 'pj_prestadora':
      return UserType.pjPrestadora;
    default:
      throw ArgumentError('Tipo de usuário inválido: $raw');
  }
}

String userTypeToString(UserType t) {
  switch (t) {
    case UserType.pfAutonoma:
      return 'pf_autonoma';
    case UserType.pfComCnpj:
      return 'pf_com_cnpj';
    case UserType.pjContratante:
      return 'pj_contratante';
    case UserType.pjPrestadora:
      return 'pj_prestadora';
  }
}
