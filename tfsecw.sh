#!/bin/bash 

echo "---------------------- Check directory"

ls ./

echo "----------------------- Run tfsec binary"

echo "$(pwd)"

# tfsec 을 다운로드 받는다. 
curl -fsSLO https://github.com/aquasecurity/tfsec/releases/download/v1.28.3/tfsec_1.28.3_linux_amd64.tar.gz

# tfsec_dir 에 압축을 풀기 위해서 디렉토리를 생성한다. 
mkdir "$(pwd)/tfsec_dir"

# 압축을 특정 디렉토리에 해제한다. 
tar xzvf tfsec_1.28.3_linux_amd64.tar.gz -C "$(pwd)/tfsec_dir"

# tfsec을 실행하고, 결과를 tfsec_results.xml 에 저장한다. 저장 타입은 junit 타입으로 저장하게 된다. 
$(pwd)/tfsec_dir/tfsec . -f junit > tfsec_results.xml