enum UserType {
  // PF
  pfAutonoma,
  pfComCnpj,
  pfContratante, // Novo tipo
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
    case 'pf_contratante': // Novo tipo
      return UserType.pfContratante;
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
    case UserType.pfContratante: // Novo tipo
      return 'pf_contratante';
    case UserType.pjContratante:
      return 'pj_contratante';
    case UserType.pjPrestadora:
      return 'pj_prestadora';
  }
}
