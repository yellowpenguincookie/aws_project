provider "local" {
}


#infra resource

resource "local_file" "foo" {
#출력파일 지정
  filename = "${path.module}/foo.txt"
  content  = data.local_file.bar.content
}

#입력 데이터파일 지정
data "local_file" "bar" {
  filename = "${path.module}/bar.txt"
}

#데이터 출력 지정
output "file_bar" {
  value = data.local_file.bar
}
