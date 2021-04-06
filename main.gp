/**
Copyright 2021 cryptoflop.org
Gestion des changements de mots de passe.
**/
randompwd(len) = {
  externstr(Str("base64 /dev/urandom | head -c ",len))[1];
}
dryrun=1;
sendmail(address,subject,message) = {
  cmd = strprintf("echo %d | mail -s '%s' %s",message,subject,address);
  if(dryrun,print(cmd),system(cmd));
}
chpasswd(user,pwd) = {
  cmd = strprintf("yes %s | passwd %s",pwd,user);
  if(dryrun,print(cmd),system(cmd));
}
template = {
  "Cher collaborateur, votre nouveau mot de passe est %s. "
  "Merci de votre comprehension, le service informatique.";
  }
change_password(user,modulus,e=7) = {
  iferr(
    pwd = randompwd(10);
    chpasswd(user, pwd);
    address = strprintf("%s@cryptoflop.org",user);
    mail = strprintf(template, pwd);
    m = fromdigits(Vec(Vecsmall(mail)),128);
    c = lift(Mod(m,modulus)^e);
    sendmail(address,"Nouveau mot de passe",c);
    print("[OK] changed password for user ",user);
  ,E,print("[ERROR] ",E));
}

encode(m) = {
	fromdigits(Vec(Vecsmall(m)),128);
}

decode(c) = {
	  Strchr(digits(c,128));
}

inp = readvec("input.txt");
chiffre = inp[2];
n = inp[1][1];
e = inp[1][2];

X = 128^10;

partiedebut = Vec(Vecsmall("Cher collaborateur, votre nouveau mot de passe est "));
partiefin = Vec(Vecsmall(". Merci de votre comprehension, le service informatique."));

m_test = concat(concat(partiedebut, Vec(0, 10)), partiefin);

m_num = fromdigits(Vec(m_test), 128);

message = zncoppersmith((m_num + 128^56*x)^e - chiffre, n, X);
print(Strprintf(template, decode(message[1])));
