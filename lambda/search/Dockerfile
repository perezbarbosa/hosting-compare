FROM public.ecr.aws/lambda/python:3.7

COPY search.py requirements.txt ./

RUN python3.7 -m pip install -r requirements.txt

# Overwrite the command by providing a different command directly in the template.
CMD ["search.handler"]