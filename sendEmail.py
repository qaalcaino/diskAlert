from email.message import EmailMessage
import smtplib
import argparse

# Proc args
parser = argparse.ArgumentParser()

parser.add_argument("-u", "--user", help="USER: ")
parser.add_argument("-p", "--paswd", help="PASSWORD: ")
parser.add_argument("-f", "--fro", help="FROM: ")
parser.add_argument("-t", "--to", help="TO: ")
parser.add_argument("-d", "--distribution", help="DISTRIBUTION: ")
parser.add_argument("-s", "--subject", help="SUBJECT: ")
parser.add_argument("-m", "--message", help="MESSAGE: ")
args = parser.parse_args()

USER=args.user
PASWD=args.paswd
FROM=args.fro
TO=args.to
DISTRIBUTION=args.distribution
SUBJECT=args.subject
MESSAGE=args.message

email = EmailMessage()
email["From"] = FROM
email["To"] = [TO, DISTRIBUTION]
email["Subject"] = SUBJECT
email.set_content(MESSAGE)
smtp = smtplib.SMTP("smtp-mail.outlook.com", port=587)
smtp.starttls()
smtp.login(USER, PASWD)
smtp.sendmail(USER, [TO, DISTRIBUTION], email.as_string())
smtp.quit()
