<!doctype html>
<html lang="en">

<head>
	<link rel="icon" type="image/png" href="https://www.nginx.com/wp-content/uploads/2019/10/favicon-48x48.ico" sizes="48x48">
	<link rel="icon" type="image/png" href="https://www.nginx.com/wp-content/uploads/2019/10/favicon-64x46.ico" sizes="64x64">
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Select tool</title>
	<link href="https://getbootstrap.com/docs/5.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-gH2yIJqKdNHPEq0n4Mqa/HGKIhSkIHeL5AyhkYV8i59U5AR6csBvApHHNl/vI1Bx" crossorigin="anonymous">
	<meta name="theme-color" content="#712cf9">
	<style>
	html,
	body {
		height: 100%;
	}

	body {
		display: flex;
		align-items: center;
		padding-top: 40px;
		padding-bottom: 40px;
		background-color: #f5f5f5;
	}

	.form-signin {
		max-width: 450px;
		padding: 15px;
	}

	.form-signin .form-floating:focus-within {
		z-index: 2;
	}

	.form-signin input[type="email"] {
		margin-bottom: -1px;
		border-bottom-right-radius: 0;
		border-bottom-left-radius: 0;
	}

	.form-signin input[type="password"] {
		margin-bottom: 10px;
		border-top-left-radius: 0;
		border-top-right-radius: 0;
	}

	table {
		width: 100%;
	}

	td {
		vertical-align: middle;
	}

	.c1 {
		width: 80px;
		text-align: left;
	}

	img {
		transition: transform .7s ease-in-out;
	}

	img:hover {
		transform: rotate(360deg);
	}
	</style>
</head>
<?php
        // Read the JSON file
        $json = file_get_contents('/opt/ml/metadata/resource-metadata.json');
        // Decode the JSON file
        $json_data = json_decode($json,true);
        $resource_arn = $json_data['ResourceArn'];
        $resource_name = $json_data['ResourceName'];
    ?>

	<body class="text-center">
		<main class="form-signin w-100 m-auto" style="max-width: 500px;">
			<p style="font-size: 12px;"> <strong>Resource ARN: </strong>
				<?php echo $resource_arn; ?>
			</p>
			<p style="font-size: 12px;"> <strong>Resource name: </strong>
				<?php echo $resource_name; ?>
			</p>
			<div style="background-color: #FFFFFF;border: 1px solid #bbb;border-radius: 10px; padding: 30px;box-shadow: 0 0 16px #ccc;">
				<table>
					<tr>
						<td class="c1"><img src="icons/vscode.png" width="64" height="64" /></td>
						<td>
							<a target="_blank" href="/proxy/1199/code/">
								<button class="w-100 btn btn-lg btn-primary" type="submit">VS Code</button>
							</a>
						</td>
					</tr>
					<tr>
						<td class="c1"><img src="icons/tb.png" width="64" height="64" /></td>
						<td>
							<a target="_blank" href="/proxy/1199/tb/">
								<button class="w-100 btn btn-lg btn-primary" type="submit">TensorBoard</button>
							</a>
						</td>
					</tr>
					<tr>
						<td class="c1"><img src="icons/ls.png" width="64" height="64" /></td>
						<td>
							<a target="_blank" href="/proxy/1199/ls/">
								<button class="w-100 btn btn-lg btn-primary" type="submit">Label Studio</button>
							</a>
						</td>
					</tr>
					<tr>
						<td class="c1"><img src="icons/f1.png" width="64" height="64" /></td>
						<td>
							<a target="_blank" href="/proxy/1199/f1/?polling=true">
								<button class="w-100 btn btn-lg btn-primary" type="submit">FiftyOne</button>
							</a>
						</td>
					</tr>
					<tr>
						<td class="c1"><img src="icons/finder.png" width="64" height="64" /></td>
						<td>
							<a target="_blank" href="/proxy/1199/finder/elfinder.html">
								<button class="w-100 btn btn-lg btn-primary" type="submit">Finder</button>
							</a>
						</td>
					</tr>
				</table>
			</div>
			<p class="mt-2 mb-3 text-muted">&copy; 2022</p>
		</main>
	</body>

</html>
