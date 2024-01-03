class Book {
  final String nume;
  final String abr;
  final String titlu;

  Book(this.nume, this.abr, this.titlu);
}

String getBookTitle(String bookAbr) {
  for (var testament in cuprins.values) {
    for (var book in testament.values) {
      if (book.abr == bookAbr) {
        return book.titlu;
      }
    }
  }
  return '';
}

final cuprins = {
  'Vechiul Testament': {
    1: Book('Întâia Carte a lui Moise', 'Fc', 'Facerea'),
    2: Book('A doua Carte a lui Moise', 'Ies', 'Ieşirea'),
    3: Book('A treia Carte a lui Moise', 'Lv', 'Leviticul'),
    4: Book('A patra Carte a lui Moise', 'Num', 'Numerii'),
    5: Book('A cincea Carte a lui Moise', 'Dt', 'Deuteronomul'),
    6: Book('', 'Ios', 'Iosua Navi'),
    7: Book('', 'Jd', 'Cartea Judecătorilor'),
    8: Book('', 'Rut', 'Rut'),
    9: Book('Cartea întâi a Regilor', '1Rg', 'I Regi'),
    10: Book('Cartea a doua a Regilor', '2Rg', 'II Regi'),
    11: Book('Cartea a treia a Regilor', '3Rg', 'III Regi'),
    12: Book('Cartea a patra a Regilor', '4Rg', 'IV Regi'),
    13: Book('Cartea întâi a Cronicilor', '1Par', 'I Paralipomena'),
    14: Book('Cartea a doua a Cronicilor', '2Par', 'II Paralipomena'),
    15: Book('Cartea întâi a lui Ezdra', '1Ezr', 'I Ezdra'),
    16: Book('Cartea a doua a lui Ezdra', 'Ne', 'Neemia'),
    17: Book('', 'Est', 'Estera'),
    18: Book('', 'Iov', 'Iov'),
    19: Book('', 'Ps', 'Psalmii'),
    20: Book('Pildele lui Solomon', 'Pr', 'Proberbe'),
    21: Book('', 'Ecc', 'Ecclesiastul'),
    22: Book('Cântarea Cântărilor', 'Cant', 'Cântări'),
    23: Book('', 'Is', 'Isaia'),
    24: Book('', 'Ir', 'Ieremia'),
    25: Book('Plângerile lui Ieremia', 'Plg', 'Plangeri'),
    26: Book('', 'Iz', 'Iezechiel'),
    27: Book('', 'Dn', 'Daniel'),
    28: Book('', 'Os', 'Osea'),
    29: Book('', 'Am', 'Amos'),
    30: Book('', 'Mi', 'Miheia'),
    31: Book('', 'Ioil', 'Ioil'),
    32: Book('', 'Avd', 'Avdie'),
    33: Book('', 'Ion', 'Iona'),
    34: Book('', 'Naum', 'Naum'),
    35: Book('', 'Avc', 'Avacum'),
    36: Book('', 'Sof', 'Sofonie'),
    37: Book('', 'Ag', 'Agheu'),
    38: Book('', 'Za', 'Zaharia'),
    39: Book('', 'Mal', 'Maleahi'),
    40: Book('', 'Tob', 'Tobit'),
    41: Book('', 'Idt', 'Iudita'),
    42: Book('', 'Bar', 'Baruh'),
    43: Book('', 'Epist', 'Epistola lui Ieremia'),
    44: Book('Cântarea celor trei tineri', 'Tin', '3 tineri'),
    45: Book('Cartea a treia a lui Ezdra', '3Ezr', 'III Ezdra'),
    46: Book('Cartea înțelepciunii lui Solomon', 'Sol', 'Solomon'),
    47: Book('Cartea înțelepciunii lui Isus, fiul lui Sirah', 'Sir', 'Sirah (Ecclesiasticul)'),
    48: Book('Istoria Susanei', 'Sus', 'Susanei'),
    49: Book('Istoria omorârii balaurului și a sfărâmării lui Bel', 'Bel', 'Bel şi Balaurul'),
    50: Book('Cartea întâi a Macabeilor', '1Mac', 'I Macabei'),
    51: Book('Cartea a doua a Macabeilor', '2Mac', 'II Macabei'),
    52: Book('Cartea a treia a Macabeilor', '3Mac', 'III Macabei'),
    53: Book('Rugăciunea regelui Manase', 'Man', 'Manase'),
  },
  'Noul Testament': {
    54: Book('Sfânta Evanghelie după Matei', 'Mt', 'Matei'),
    55: Book('Sfânta Evanghelie după Marcu', 'Mc', 'Marcu'),
    56: Book('Sfânta Evanghelie după Luca', 'Lc', 'Luca'),
    57: Book('Sfânta Evanghelie după Ioan', 'In', 'Ioan'),
    58: Book('', 'FA', 'Faptele Sfinților Apostoli'),
    59: Book('Ep. către Romani a Sf. Ap. Pavel', 'Rm', 'Romani'),
    60: Book('Ep. I către Corinteni a Sf. Ap. Pavel', '1Co', 'I Corinteni'),
    61: Book('Ep. II către Corinteni a Sf. Ap. Pavel', '2Co', 'II Corinteni'),
    62: Book('Ep. către Galateni a Sf. Ap. Pavel', 'Ga', 'Galateni'),
    63: Book('Ep. către Efeseni a Sf. Ap. Pavel', 'Ef', 'Efeseni'),
    64: Book('Ep. către Filipeni a Sf. Ap. Pavel', 'Flp', 'Filipeni'),
    65: Book('Ep. către Coloseni a Sf. Ap. Pavel', 'Col', 'Coloseni'),
    66: Book('Ep. I către Tesaloniceni a Sf. Ap. Pavel', '1Tes', 'I Tesaloniceni'),
    67: Book('Ep. II către Tesaloniceni a Sf. Ap. Pavel', '2Tes', 'II Tesaloniceni'),
    68: Book('Ep. I către Timotei a Sf. Ap. Pavel', '1Tim', 'I Timotei'),
    69: Book('Ep. II către Timotei a Sf. Ap. Pavel', '2Tim', 'II Timotei'),
    70: Book('Ep. către Tit a Sf. Ap. Pavel', 'Tit', 'Tit'),
    71: Book('Ep. către Filimon a Sf. Ap. Pavel', 'Flm', 'Filimon'),
    72: Book('Ep. către Evrei a Sf. Ap. Pavel', 'Evr', 'Evrei'),
    73: Book('Ep. Sobornicească a Sf. Ap. Iacov', 'Iac', 'Iacov'),
    74: Book('I-a Ep. Sobornicească a Sf. Ap. Petru', '1Ptr', 'I Petru'),
    75: Book('A doua Ep. Sobornicească a Sf. Ap. Petru', '2Ptr', 'II Petru'),
    76: Book('I-a Ep. Sobornicească a Sf. Ap. Ioan', '1In', 'I Ioan'),
    77: Book('A doua Ep. Sobornicească a Sf. Ap. Ioan', '2In', 'II Ioan'),
    78: Book('A treia Ep. Sobornicească a Sf. Ap. Ioan', '3In', 'III Ioan'),
    79: Book('Ep. Sobornicească a Sf. Ap. Iuda', 'Iuda', 'Iuda'),
    80: Book('Apocalipsa Sf. Ioan Teologul', 'Ap', 'Apocalipsa'),
  },
};
