#!/bin/bash
# Default Content :: ${FILE, path="$WORKSPACE/prod-repo/sources/Jenkins-Notice/mail_content.html"}

#######################################
function mail_template() {
  cd $WORKSPACE/prod-repo/sources/Jenkins-Notice
  rm -rf mail_content.html
  DEPLOY_URL_PREFIIX=$(echo $K8S_NAMESPACE | cut -f2 -d"-")

      if [[ $DEPLOY_URL_PREFIIX == prod ]] ; then
          REAL_DEPLOY_URL_PREFIIX=www
      else
          REAL_DEPLOY_URL_PREFIIX=$DEPLOY_URL_PREFIIX
      fi

cat << EOF >> mail_content.html
<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">

<head>
  <title> </title>
  <!--[if !mso]><!-- -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <!--<![endif]-->
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
    #outlook a {
      padding: 0;
    }

    .ReadMsgBody {
      width: 100%;
    }

    .ExternalClass {
      width: 100%;
    }

    .ExternalClass * {
      line-height: 100%;
    }

    body {
      margin: 0;
      padding: 0;
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }

    table,
    td {
      border-collapse: collapse;
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }

    img {
      border: 0;
      height: auto;
      line-height: 100%;
      outline: none;
      text-decoration: none;
      -ms-interpolation-mode: bicubic;
    }

    p {
      display: block;
      margin: 13px 0;
    }
  </style>
  <!--[if !mso]><!-->
  <style type="text/css">
    @media only screen and (max-width:480px) {
      @-ms-viewport {
        width: 320px;
      }

      @viewport {
        width: 320px;
      }
    }
  </style>
  <!--<![endif]-->
  <!--[if mso]>
        <xml>
        <o:OfficeDocumentSettings>
          <o:AllowPNG/>
          <o:PixelsPerInch>96</o:PixelsPerInch>
        </o:OfficeDocumentSettings>
        </xml>
        <![endif]-->
  <!--[if lte mso 11]>
        <style type="text/css">
          .outlook-group-fix { width:100% !important; }
        </style>
        <![endif]-->
  <!--[if !mso]><!-->
  <link href="https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700" rel="stylesheet" type="text/css">
  <style type="text/css">
    @import url(https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700);
  </style>
  <!--<![endif]-->
  <style type="text/css">
    @media only screen and (min-width:480px) {
      .mj-column-per-100 {
        width: 100% !important;
        max-width: 100%;
      }
    }
  </style>
  <style type="text/css">
    @media only screen and (max-width:480px) {
      table.full-width-mobile {
        width: 100% !important;
      }

      td.full-width-mobile {
        width: auto !important;
      }
    }
  </style>
</head>

<body>
  <div style="">
    <!--[if mso | IE]>
      <table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
        <tr>
          <td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
      <![endif]-->
    <div style="Margin:0px auto;max-width:600px;">
      <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
        <tbody>
          <tr>
            <td style="direction:ltr;font-size:0px;padding:20px 0;padding-bottom:0p;padding-top:50px;text-align:center;vertical-align:top;">
              <!--[if mso | IE]>
                <table role="presentation" border="0" cellpadding="0" cellspacing="0">
                  <tr>
                    <td class="" style="vertical-align:top;width:600px;">
                <![endif]-->
              <div class="mj-column-per-100 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">
                <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">
                  <tr>
                    <td align="center" style="font-size:0px;padding:10px 25px;padding-top:0;padding-right:0px;padding-bottom:0px;padding-left:0px;word-break:break-word;">
                      <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;border-spacing:0px;">
                        <tbody>
                          <tr>
                            <td style="width:182px;">
                              <a href="https://mjml.io" target="_blank">
                                <img alt="Amario logo" height="auto" src="https://xblockchainlabs.com/wp-content/uploads/2018/03/logo-draft.png"
                                  style="border:none;display:block;outline:none;text-decoration:none;height:auto;width:100%;"
                                  width="182" />
                              </a>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </td>
                  </tr>
                </table>
              </div>
              <!--[if mso | IE]>
                  </td>
                </tr>
              </table>
              <![endif]-->
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <!--[if mso | IE]>
          </td>
        </tr>
      </table>
      
      <table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
        <tr>
          <td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
      <![endif]-->
    <div style="background:#adffb1;background-color:#adffb1;Margin:0px auto;max-width:600px;">
      <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background:#adffb1;background-color:#adffb1;width:100%;">
        <tbody>
          <tr>
            <td style="direction:ltr;font-size:0px;padding:20px 0;padding-bottom:0;padding-top:0;text-align:center;vertical-align:top;">
              <!--[if mso | IE]>
              <table role="presentation" border="0" cellpadding="0" cellspacing="0">
                <tr>
                  <td class="" style="vertical-align:top;width:600px;">
              <![endif]-->
              <div class="mj-column-per-100 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">
                <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">
                  <tr>
                    <td align="left" style="font-size:0px;padding:10px 25px;padding-top:0;padding-right:25px;padding-bottom:0px;padding-left:25px;word-break:break-word;">
                      <div style="font-family:Ubuntu, Helvetica, Arial, sans-serif, Helvetica, Arial, sans-serif;font-size:13px;line-height:1;text-align:left;color:#000000;">
                        <p><span style="color: #00561e; font-size: 16px;">
                          <span style="width: 20px; display: inline-block;">&#10003;</span>
                            Deployed on 
                          <a style="color: #00561e; text-decoration: none; text-transform: uppercase; white-space: no-wrap;" href="https://$REAL_DEPLOY_URL_PREFIIX.example.com"
                              target="_blank"><strong>$REAL_DEPLOY_URL_PREFIIX</strong><sup style="padding-left:3px; color: #999;">&#10138;</sup></a>
                          </span>
                        </p>
                        <p style="padding-left: 25px;"> <span style="font-size: 10px;">Jenkins Build
                            #<a style="color: #00561e; font-size:11px; text-decoration: none; font-weight: bold;" href="$BUILD_URL/console"
                              target="_blank">$BUILD_NUMBER<sup style="padding-left:3px; color: #999;">&#10138;</sup></a>
                          </span></p>
                      </div>
                    </td>
                  </tr>
                </table>
              </div>
              <!--[if mso | IE]>
                  </td>
                </tr>
              </table>
            <![endif]-->
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <!--[if mso | IE]>
          </td>
        </tr>
      </table>
      
      <table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
        <tr>
          <td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
      <![endif]-->
    <div style="Margin:0px auto;max-width:600px;">
      <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="width:100%;">
        <tbody>
          <tr>
            <td style="direction:ltr;font-size:0px;padding:20px 0;padding-top:15px;text-align:center;vertical-align:top;">
              <!--[if mso | IE]>
              <table role="presentation" border="0" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="left" class="" style="">
              <![endif]-->
              <table cellpadding="0" cellspacing="0" width="100%" border="0" style="cellspacing:0;color:#000000;font-family:Ubuntu, Helvetica, Arial, sans-serif;font-size:13px;line-height:22px;table-layout:auto;width:100%;">
                <tr style="text-align:left;padding:15px 0; background-color: #555;">
                  <th style="padding: 5px;border:1px solid #ddd;color: #fff;font-weight: normal;">CICD Module Name</th>
                  <th style="padding: 5px;border:1px solid #ddd;color: #fff;font-weight: normal;"><strong></strong>Repository
                    Name</th>
                  <th style="padding: 5px;border:1px solid #ddd;color: #fff;font-weight: normal;">Commit Version</th>
                  <th style="padding: 5px;border:1px solid #ddd;color: #fff;font-weight: normal;">Last Commit (GMT)</th>
                </tr>
EOF
  cd $P_W_D
  export IDENTIFY_NO=""
  for repo_project in ${repo_projects[@]}; do
      if [[ $K8S_NAMESPACE == example-prod ]] ; then
        echo "DEVOPS_NOTICE :: Production is using stage Images"
        export P_W_D=$PWD ; cd  /var/lib/jenkins/workspace/example-stage/$repo_project/
      elif [[ $K8S_NAMESPACE == example-prod-special ]] ; then
        echo "DEVOPS_NOTICE :: Production is using stage Images"
        export P_W_D=$PWD ; cd  /var/lib/jenkins/workspace/special-stage/$repo_project/
      else
        export P_W_D=$PWD ; cd $WORKSPACE/$repo_project/
      fi
      # Generating Commit ID URL
      GIT_MAIL_ORG=$(git config --get remote.origin.url | cut -f2 -d":" | cut -f1 -d"/")
      GIT_MAIL_REPO=$(basename -s .git `git config --get remote.origin.url`)
      GIT_MAIL_LAST_COMMIT=$(git log --format="%H" -n 1)
      GIT_MAIL_COMMIT_VERSION=$(git rev-parse --short HEAD)
      GIT_MAIL_URL=https://github.com/$GIT_MAIL_ORG/$GIT_MAIL_REPO/tree/$GIT_MAIL_LAST_COMMIT
      # Generating Branch Name
      GIT_MAIL_BRANCH=$(git show-ref | grep $(git rev-parse HEAD) | grep remotes | grep -v HEAD | sed -e 's/.*remotes.origin.//')
      # Commit Date
      GIT_MAIL_COMMIT_DATE=$(TZ=GMT git log -n 1 --date=local | grep -i ^date | sed "s/Date: //g")

      cd $WORKSPACE/prod-repo/sources/Jenkins-Notice
      if [[ -z "$IDENTIFY_NO" ]] ; then
cat << EOF >> mail_content.html
                <tr>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;text-align:left;">$repo_project</td>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;text-align:left;font-weight: bold;">$GIT_MAIL_REPO</td>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333; text-align: center;"><a style="color: #389EBA; font-weight: bold; text-decoration: none; white-space: no-wrap;"
                      href="$GIT_MAIL_URL"
                      target="_blank">$GIT_MAIL_COMMIT_VERSION<sup style="padding-left:3px; color: #999;">&#10138;</sup></a></td>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;text-align:left;">$GIT_MAIL_COMMIT_DATE</td>
                </tr>
EOF
        export IDENTIFY_NO="0"
      else
cat << EOF >> mail_content.html
                <tr>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;text-align:left;background-color: #eafaff;">$repo_project</td>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;text-align:left;font-weight: bold;background-color: #eafaff;">$GIT_MAIL_REPO</td>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;background-color: #eafaff; text-align: center;"><a
                      style="color: #389EBA; font-weight: bold; text-decoration: none; white-space: no-wrap;" href="$GIT_MAIL_URL"
                      target="_blank">$GIT_MAIL_COMMIT_VERSION<sup style="padding-left:3px; color: #999;">&#10138;</sup></a></td>
                  <td style="padding: 5px;border:1px solid #ddd;color:#333;text-align:left;background-color: #eafaff;">$GIT_MAIL_COMMIT_DATE</td>
                </tr>
EOF
       export IDENTIFY_NO=""
      fi

  done
cat << EOF >> mail_content.html
              </table>
              <!--[if mso | IE]>
                    </td>
                  </tr>
                </table>
              <![endif]-->
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <!--[if mso | IE]>
          </td>
        </tr>
      </table>
      <![endif]-->
  </div>
</body>

</html>
EOF
}

cd $WORKSPACE/

mail_template