#!/usr/bin/env python3
"""
TG - Técnicas de Mascaramento e Anonimização de Dados em Bancos Relacionais Oracle
Etapa 01: acrescenta CPF e CEP sintéticos (formato brasileiro válido) às duas bases.

Entrada : <entrada>/Training_Set.xlsx  e  <entrada>/Testing_Set.xlsx
Saída   : <saida>/Training_Set_com_CPF_CEP.xlsx  e  <saida>/Testing_Set_com_CPF_CEP.xlsx

Reprodutibilidade
  - Semente fixa (42), usada uma única vez, e ordem fixa de processamento
    (Training_Set primeiro, Testing_Set depois). Mudar a ordem muda os valores gerados.
  - Use as versões de bibliotecas do requirements.txt.

Observação sobre o gerador
  O Faker (pt_BR) sorteia os 9 primeiros dígitos do CPF SEM repetição
  (random.sample), o que limita o espaço a 3.628.800 CPFs. Por isso a base de
  45.000 registros tem CPFs repetidos (44.712 distintos). Ver README, seção
  "Limitações".

Uso
    python gerar_cpf_cep.py --entrada dados --saida saida
"""
import argparse
import os
import re

import pandas as pd
from faker import Faker

SEMENTE = 42

fake = Faker("pt_BR")
Faker.seed(SEMENTE)


def gerar_cpf():
    """CPF com dígitos verificadores válidos, formato 000.000.000-00."""
    return fake.cpf()


def gerar_cep():
    """CEP no formato 00000-000 (o Faker devolve formatos inconsistentes)."""
    raw = fake.postcode()
    digits = re.sub(r"\D", "", raw)
    digits = digits.ljust(8, "0")[:8]
    return f"{digits[:5]}-{digits[5:]}"


def validar_cpf(cpf):
    nums = re.sub(r"\D", "", cpf)
    if len(nums) != 11 or nums == nums[0] * 11:
        return False

    def dv(base, peso_inicial):
        soma = sum(int(d) * p for d, p in zip(base, range(peso_inicial, 1, -1)))
        r = (soma * 10) % 11
        return 0 if r == 10 else r

    d1 = dv(nums[:9], 10)
    d2 = dv(nums[:9] + str(d1), 11)
    return nums[-2:] == f"{d1}{d2}"


def processar_base(caminho_entrada, caminho_saida, nome):
    print(f"Processando {nome}...")
    df = pd.read_excel(caminho_entrada)
    n = len(df)

    df["CPF"] = [gerar_cpf() for _ in range(n)]
    df["CEP"] = [gerar_cep() for _ in range(n)]

    # CPF e CEP logo após SSN; Text e True Predictions continuam no fim
    cols = list(df.columns)
    cols.remove("CPF")
    cols.remove("CEP")
    pos = cols.index("SSN")
    cols = cols[: pos + 1] + ["CPF", "CEP"] + cols[pos + 1:]
    df = df[cols]

    df.to_excel(caminho_saida, index=False)
    return df


def validar(df, nome):
    n = len(df)
    cpfs_validos = int(df["CPF"].apply(validar_cpf).sum())
    ceps_ok = int(df["CEP"].str.match(r"^\d{5}-\d{3}$").sum())
    nulos = int(df[["CPF", "CEP"]].isnull().sum().sum())
    distintos = int(df["CPF"].nunique())
    print(f"  {nome}: {n} registros")
    print(f"    CPFs com dígito verificador válido: {cpfs_validos}/{n}")
    print(f"    CEPs no formato 00000-000:          {ceps_ok}/{n}")
    print(f"    Nulos em CPF/CEP:                   {nulos}")
    print(f"    CPFs distintos:                     {distintos} ({n - distintos} repetidos)")


def main():
    ap = argparse.ArgumentParser(description="Gera CPF e CEP sintéticos para as bases do TG.")
    ap.add_argument("--entrada", default="dados", help="pasta com Training_Set.xlsx e Testing_Set.xlsx")
    ap.add_argument("--saida", default="saida", help="pasta de saída")
    args = ap.parse_args()

    os.makedirs(args.saida, exist_ok=True)
    # A ORDEM IMPORTA: a semente é compartilhada entre as duas bases.
    for base in ("Training_Set", "Testing_Set"):
        df = processar_base(
            os.path.join(args.entrada, f"{base}.xlsx"),
            os.path.join(args.saida, f"{base}_com_CPF_CEP.xlsx"),
            base,
        )
        validar(df, base)


if __name__ == "__main__":
    main()
