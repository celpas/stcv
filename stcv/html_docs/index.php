<!DOCTYPE html>
<html lang="en">
    <head>
        <link rel="icon" type="image/png" href="https://www.nginx.com/wp-content/uploads/2019/10/favicon-48x48.ico" sizes="48x48" />
        <link rel="icon" type="image/png" href="https://www.nginx.com/wp-content/uploads/2019/10/favicon-64x46.ico" sizes="64x64" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>STCV v2</title>
        <style>
            html,
            body {
                height: 100%;
                text-align: center;
            }

            body {
                display: flex;
                padding-top: 40px;
                padding-bottom: 40px;
                background-color: #457b9d;
                font-family: verdana;
                color: #f1faee;
            }

            h4 {
                margin: 15px 0;
                font-size: 32px;
            }

            img {
                transition: transform 0.7s ease-in-out;
            }

            img:hover {
                transform: rotate(360deg) scale(1.1);
            }

            #container {
                margin: 0 auto;
                width: 1024px;
            }

            #grid {
                background-color: #ffffff;
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                padding: 20px;
                box-shadow: 15px 15px 0 #a8dadc;
            }

            #grid .tool {
                padding: 20px;
            }

            #grid .tool_icon {
                margin-bottom: 20px;
            }

            #grid .active button {
                background-color: #57cc99;
                border: 2px solid #57cc99;
            }

            #grid .disabled button {
                background-color: #e63946;
                border: 2px solid #e63946;
            }

            .tool_button {
                background-color: #1d3557;
                color: #f1faee;
                border: 2px solid #1d3557;
                padding: 5px 0;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                font-size: 16px;
                transition-duration: 0.4s;
                width: 100%;
                font-size: 14px;
            }

            .tool_button:hover {
                background-color: white !important;
                color: black !important;
            }

            .tool_button span {
                cursor: pointer;
                display: inline-block;
                position: relative;
                transition: 0.5s;
            }

            .tool_button span:after {
                content: "\00bb";
                position: absolute;
                opacity: 0;
                top: 0;
                right: -20px;
                transition: 0.5s;
            }

            .tool_button:hover span {
                padding-right: 25px;
            }

            .tool_button:hover span:after {
                opacity: 1;
                right: 0;
            }

            #footer {
                margin: 30px 0;
            }
        </style>
    </head>

    <body class="text-center">
        <main id="container">
            <h4><b>S</b>ageMaker <b>T</b>oolkit for <b>C</b>omputer <b>V</b>ision</h4>
            <div id="grid">
                <div class="tool">
                    <div class="tool_icon"><img src="icons/jp.png" width="64" height="64" /></div>
                    <div class="tool_desc active">
                        <a target="_blank" href="/lab">
                            <button class="tool_button" type="submit"><span>JupyterLab </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/vscode.png" width="64" height="64" /></div>
                    <div class="tool_desc active">
                        <a target="_blank" href="/proxy/1123/code/">
                            <button class="tool_button" type="submit"><span>VS Code </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/mlflow.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_MLFLOW_1_ENABLE'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/mlflow_1/">
                            <button class="tool_button" type="submit"><span>MLFlow (session 1)</span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/mlflow.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_MLFLOW_2_ENABLE'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/mlflow_2/">
                            <button class="tool_button" type="submit"><span>MLFlow (session 2)</span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/tb.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_TENSORBOARD_1_ENABLE'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/tb_1/">
                            <button class="tool_button" type="submit"><span>TensorBoard (session 1)</span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/tb.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_TENSORBOARD_2_ENABLE'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/tb_2/">
                            <button class="tool_button" type="submit"><span>TensorBoard (session 2)</span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/ls.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_LABELSTUDIO_ENABLE'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/ls/">
                            <button class="tool_button" type="submit"><span>Label Studio </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/finder.png" width="64" height="64" /></div>
                    <div class="tool_desc active">
                        <a target="_blank" href="/proxy/1123/finder/elfinder.html">
                            <button class="tool_button" type="submit"><span>elFinder </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/f1.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_FIFTYONE_1_BUILD'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/f1_1/?polling=true">
                            <button class="tool_button" type="submit"><span>FiftyOne (session 1) </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/f1.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_FIFTYONE_2_BUILD'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/f1_2/?polling=true">
                            <button class="tool_button" type="submit"><span>FiftyOne (session 2) </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/f1.png" width="64" height="64" /></div>
                    <div class="tool_desc <?php if ($_ENV['STCV_FIFTYONE_3_BUILD'] == 'True') { echo 'active'; } else { echo 'disabled'; }; ?>">
                        <a target="_blank" href="/proxy/1123/f1_3/?polling=true">
                            <button class="tool_button" type="submit"><span>FiftyOne (session 3) </span></button>
                        </a>
                    </div>
                </div>
                <div class="tool">
                    <div class="tool_icon"><img src="icons/ez.png" width="64" height="64" /></div>
                    <div class="tool_desc active">
                        <a target="_blank" href="/proxy/1123/ez/">
                            <button class="tool_button" type="submit"><span>Server Monitoring </span></button>
                        </a>
                    </div>
                </div>
            </div>
            <div id="footer">STCV version <?php echo $_ENV["STCV_VERSION"]; ?></div>
        </main>
    </body>
</html>
