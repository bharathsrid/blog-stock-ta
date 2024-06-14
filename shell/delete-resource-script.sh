# Parse options passed
bucket_name=""
stack_name=""
aws_region=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --bucket-name-to-delete)
            bucket_name="$2"
            shift 2
            ;;
        --stack-name)
            stack_name="$2"
            shift 2
            ;;
        --aws-region)
            aws_region="$2"
            shift 2
            ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
done

# Check if both parameters are provided
if [ -z "${bucket_name}" ] || [ -z "${stack_name}" ] || [ -z "${aws_region}" ]; then
    echo "Error: --bucket-name-to-delete, --stack-name and --aws-region are required." >&2
    exit 1
fi

aws s3 rm s3://${bucket_name} --region ${aws_region} --recursive --profile child
aws s3 rb s3://${bucket_name} --region ${aws_region} --profile child

echo "Deleting CloudFormation Stack: $stack_name"

aws cloudformation delete-stack --stack-name $stack_name --region ${aws_region} --profile child
aws cloudformation describe-stacks --stack-name $stack_name --region ${aws_region} --query "Stacks[0].StackStatus" --profile child

aws cloudformation wait stack-delete-complete --stack-name $stack_name --region ${aws_region} --profile child
echo "DELETE_COMPLETE"
