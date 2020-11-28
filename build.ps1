$win_tag = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId

$appname="kafka_dockeree"

#$ce_memopt="-m 2GB"
$ce_memopt=""

write-output "building for windows ${win_tag}"
docker build ${ce_memopt} -t ${appname}_server:${win_tag} . --build-arg win_tag=${win_tag}
