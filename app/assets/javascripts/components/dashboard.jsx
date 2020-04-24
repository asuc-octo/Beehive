class Dashboard extends React.Component {
  	render() {
  		let tab_content;
		let researchStatus;
		let undergradStatus;
  		if (this.props.undergrad){
  			undergradStatus = "active"
  			researchStatus = ""
		} else {
			undergradStatus = ""
  			researchStatus = "active"
		}
		return <div className="container" id="dashboard">
			  		<h1>Dashboard</h1>
					<div className="tabs-container">
					    <div className="btn-group" data-toggle="buttons" role="group">
					    	<TabButton status={undergradStatus} target="#browse" id="browsebtn" controls="browse" expanded="true" label="Undergrads" /> 
					        <TabButton status={researchStatus} target="#post" id="postbtn" controls="post" expanded="false" label="Researchers" /> 
					    </div>
			  		</div>
					<div className="tab-content">
						<div className={"tab-pane " + researchStatus} id="post">
							<ProjectTable table_name="Applications Received" empty={this.props.ownappsEmpty} empty_text="You have not yet received any applications." table_data={this.props.ownappsTableData} />
				        	<ProjectList list_name="Manage Projects" empty={this.props.jobsEmpty} default_message="You have not posted any projects. <a href='/jobs/new'>Post one</a> now." jobs={this.props.jobsTableList} />
					    </div>
					    <div className={"tab-pane " + undergradStatus} id="browse">
					      	<ProjectTable table_name="Your Applications" empty={this.props.applicsEmpty} empty_text="You have not applied to any research positions." table_data={this.props.applicsTableData} />
					        <ProjectList list_name="Watched Projects" empty={this.props.watchedJobsEmpty} default_message="You are not watching any projects." jobs={this.props.watchedJobsTableList} />
					    </div>
			  		</div>
				</div>
  	}
}

class TabButton extends React.Component {
	render(){
		return  <label className={"btn btn-primary " + this.props.status} data-target={this.props.target} data-toggle="tab" id={this.props.id}>
		        	<input aria-controls={this.props.controls} aria-expanded={this.props.expanded} autoComplete="off" checked="checked" type="radio" value={this.props.label} />{this.props.label}
		        </label>
	}
}