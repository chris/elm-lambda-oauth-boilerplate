# Elm Lambda OAuth Boilerplate

This repo is a mono-repo, containing both the frontend and backend code for a basic boilerplate
that does OAuth for an Elm application, using an AWS Lambda function for the OAuth callback
handler.

This sample uses Strava as the OAuth provider.

The Elm application is deployed as static JavaScript, and redirects users to Strava to
authenticate. It specifies the URL to an AWS Lambda function as the OAuth callback. That callback,
will then redirect back to the Elm application, passing it a JWT token if authentication was
successful. The Elm application will then save the JWT token to local storage, as well as remove
it from the URL so that it doesn't get bookmarked or have the user wonder about it. This is NOT a
security measure, it's more about having a nice UX.

Note, you should be able to use any OAuth 2 compliant service to do auth. You will just need to
change the URL the Elm app redirects to if you don't use Strava.

This system uses the [Serverless framework](https://serverless.com/) for implementation and
deployment of the AWS Lambda function.

To use this or try it out yourself:

1.  Setup an application on Strava (or your authentication system of choice).
1.  Configure the OAuth keys in `server/env.yml`.
1.  Configure the frontend application URL in `server/env.yml`. Note you can use localhost:8080,
    for a locally running frontend app.
1.  Create a key to be used for JWT encoding, and set this in `server/env.yml`.
1.  Configure your IAM user in serverless.yml (and add any other configuration your account may
    need here in order for [Serverless](https://serverless.com/) to deploy.)
1.  Configure an AWS role to support Serverless deploy. Your user will need to have the
    AWSLambdaFullAccess policy, as well as:
    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Stmt1478749816000",
                "Effect": "Allow",
                "Action": [
                    "cloudformation:*",
                    "iam:CreateRole",
                    "iam:DeleteRolePolicy",
                    "iam:GetRole",
                    "iam:PutRolePolicy",
                    "apigateway:*"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }
    ```
1.  Deploy the Lambda function (from within the `server` directory) using `serverless deploy`.
1.  Take the URL you got from that deploy and fix the `oauth_redirect_url` value in
    `frontend/src/elm/Main.elm`.
1.  Put your Strava client ID into `strava_oauth_url` in `frontend/src/elm/Main.elm`, and/or
    update the URL with the OAuth endpoint for the service you're using.
1.  Run the Frontend app (see README.md in the `frontend` directory).

